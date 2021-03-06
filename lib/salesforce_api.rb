require 'rest-client'

# Allows you to call into the Salesforce API and retrieve information.
# Example Usage:
# contact_info = SalesforceAPI.client.get_contact_info('some_sf_contact_id')
class SalesforceAPI

  # Pass these into any POST or PUT request where the body is json.
  JSON_HEADERS = {content_type: :json, accept: :json}

  class SalesforceDataError < StandardError; end

  # Use this to get an authenticated instance of the API client
  def self.client
    s = new
    s.authenticate
  end

  def authenticate
    # For authentication against the Salesforce API we use what is called a Session ID token as detailed here:
    # https://developer.salesforce.com/docs/atlas.en-us.api_rest.meta/api_rest/quickstart_oauth.htm 
    auth_params = {
      :grant_type => 'password',
      :client_id => ENV['SALESFORCE_PLATFORM_CONSUMER_KEY'],
      :client_secret => ENV['SALESFORCE_PLATFORM_CONSUMER_SECRET'],
      :username => ENV['SALESFORCE_PLATFORM_USERNAME'],
      :password => ENV['SALESFORCE_PLATFORM_PASSWORD'] + ENV['SALESFORCE_PLATFORM_SECURITY_TOKEN']
    }
  
    # TODO: this endpoint is really only supposed to be for dev env testing. Once we figure out how to hookup this stuff
    # to Salesforce, ideally switch to use the JWT/JWK bearer flow:
    #  - https://help.salesforce.com/articleView?id=remoteaccess_oauth_jwt_flow.htm&type=5
    # or one of the other OAuth flows if we want the access token to be on a per user basis.
    #  - https://help.salesforce.com/articleView?id=remoteaccess_oauth_flows.htm&type=5
    token_response = RestClient.post("https://#{ENV['SALESFORCE_HOST']}/services/oauth2/token", auth_params)
    token_response_json = JSON.parse(token_response.body)

    # There are generic Salesforce URLs like: 
    #  - https://login.salesforce.com
    #  - https://test.salesforce.com 
    # But when using the API we need to hit the actual instance our Salesforce account is hosted on. E.g.
    #  - https://na74.my.salesforce.com/
    #  - https://bebraven--Staging.cs22.my.salesforce.com
    @salesforce_url = token_response_json['instance_url']
    @access_token = token_response_json['access_token']
    @global_headers = { 'Authorization' => "Bearer #{@access_token}" }
    self
  end

  def get(path, params={}, headers={})
    RestClient.get("#{@salesforce_url}#{path}", {params: params}.merge(@global_headers.merge(headers)))
  rescue => e
    handle_rest_client_error(e)
  end

  def post(path, body, headers={})
    RestClient.post("#{@salesforce_url}#{path}", body, @global_headers.merge(headers))
  rescue => e
    handle_rest_client_error(e)
  end

  def put(path, body, headers={})
    RestClient.put("#{@salesforce_url}#{path}", body, @global_headers.merge(headers))
  rescue => e
    handle_rest_client_error(e)
  end

  def patch(path, body, headers={})
    RestClient.patch("#{@salesforce_url}#{path}", body, @global_headers.merge(headers))
  rescue => e
    handle_rest_client_error(e)
  end

  def get_program_info(program_id)
    soql_query = 
      "SELECT Id, Name, Target_Course_ID_in_LMS__c, LMS_Coach_Course_Id__c, School__c, " \
        "Section_Name_in_LMS_Coach_Course__c, Default_Timezone__c, Docusign_Template_ID__c, " \
        "Preaccelerator_Qualtrics_Survey_ID__c, Postaccelerator_Qualtrics_Survey_ID__c, " \
        "LC_DocuSign_Template_ID__c " \
      "FROM Program__c WHERE Id = '#{program_id}'"

    response = get("/services/data/v48.0/query?q=#{CGI.escape(soql_query)}")
    JSON.parse(response.body)['records'][0]
  end

  # Gets a list of all Participants in the Program. These are folks who are
  # enrolled and should have Portal access.
  #
  # program_id: if specified, filters the Participants returned down to only that Program. E.g. a2Y1J000000YpQFUA0
  # contact_id: if specified, filters the Participants returned down to only that Contact. E.g. 0037A00000RUoz4QAD
  # last_modified_since: specifies that we should only get participants whose info has been  modified since this value.

  # TODO: need to figure out what format we need to use. The below format is what is sent back from SF
  # for the date, but need to make sure I can convert that to a SOQL query and filter on it.

  # The format is the Salesforce database datetime format in GMT. For example:
  #    2020-04-06T20:19:23.000+0000 
  # Also, it's only down to the second precision, not millisecond.
  def get_participants(program_id = nil, contact_id = nil, last_modified_since = nil)
    query_params = ''
    if program_id || contact_id || last_modified_since
      query_params = '?'
      query_params += "program_id=#{program_id}&" if program_id
      query_params += "contact_id=#{contact_id}&" if contact_id
      query_params += "last_modified_since=#{CGI.escape(last_modified_since)}&" if last_modified_since 
      query_params.chop! # Remove the trailing &
    end
    # Defined in BZ_ProgramParticipantInfoService Apex class in Salesforce
    response = get("/services/apexrest/participants/currentandfuture/#{query_params}") 
    JSON.parse(response.body)
  end

  # Get information about a Contact record
  def get_contact_info(contact_id)
    response = get("/services/data/v48.0/sobjects/Contact/#{contact_id}" \
      "?fields=Id,FirstName,LastName,Email,Phone,BZ_Region__c,Preferred_First_Name__c,CreatedDate,Signup_Date__c," \
      "IsEmailBounced,BZ_Geographical_Region__c,Current_Employer__c,Career__c,Title,Job_Function__c,Current_Major__c," \
      "High_School_Graduation_Date__c,Anticipated_Graduation__c,Graduate_Year__c")
    JSON.parse(response.body)
  end

  def set_canvas_id(contact_id, canvas_id)
    body = { 'Canvas_User_ID__c' => canvas_id }
    response = patch("/services/data/v48.0/sobjects/Contact/#{contact_id}", body.to_json, JSON_HEADERS)
  end

# TODO: delete me if we don't need to use a POST for any reason. I figured out how to accept query params in the get after I had implement this.
# I'm assuming we'll be fine sending the request to SF in a get and not need this, but just in case I"m leaving this around until we've fully
# implemented the flow and know we won't use it.
#  # Same as get_participant_data(), but only for the specified course_id
#  def get_participant_data_for_course(course_id, last_modified_since = nil)
#    body = {
#      "courseId" => "#{course_id}",
#      "last_modified_since" => last_modified_since
#    }
#    post("/services/apexrest/participants/currentandfuture/", body.to_json, JSON_HEADERS) # Defined in BZ_ProgramParticipantInfoService apex class in Salesforce
#  end

  def handle_rest_client_error(e)
    Rails.logger.error("{\"Error\":\"#{e.message}\"}")
    Rails.logger.error(e.response.body)
    raise
  end

end
