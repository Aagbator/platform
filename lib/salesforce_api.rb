require 'rest-client'

class SalesforceAPI

  # Pass these into any POST or PUT request where the body is json.
  JSON_HEADERS = {content_type: :json, accept: :json}

  def initialize
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
  end

  def get(path, params={}, headers={})
    RestClient.get("#{@salesforce_url}#{path}", {params: params}.merge(@global_headers.merge(headers)))
  end

  def post(path, body, headers={})
    RestClient.post("#{@salesforce_url}#{path}", body, @global_headers.merge(headers))
  end

  def put(path, body, headers={})
    RestClient.put("#{@salesforce_url}#{path}", body, @global_headers.merge(headers))
  end

  def get_program_info(course_id)
    soql_query = 
      "SELECT Id, Name, Target_Course_ID_in_LMS__c, LMS_Coach_Course_Id__c, School__c, " \
        "Section_Name_in_LMS_Coach_Course__c, Default_Timezone__c, Docusign_Template_ID__c, " \
        "Preaccelerator_Qualtrics_Survey_ID__c, Postaccelerator_Qualtrics_Survey_ID__c " \
      "FROM Program__c WHERE Target_Course_ID_in_LMS__c = '#{course_id}'"

    response = get("/services/data/v48.0/query?q=#{CGI.escape(soql_query)}")
    JSON.parse(response.body)['records'][0]
  end

  # Gets a list of all Participants in the Program. These are folks who are
  # enrolled and should have Portal access.
  #
  # last_modified_since: specifies that we should only get participants whose info has been  modified since this value.

  # TODO: need to figure out what format we need to use. The below format is what is sent back from SF
  # for the date, but need to make sure I can convert that to a SOQL query and filter on it.

  # The format is the Salesforce database datetime format in GMT. For example:
  #    2020-04-06T20:19:23.000+0000 
  # Also, it's only down to the second precision, not millisecond.
  def get_participants(course_id, last_modified_since = nil)
    query_params = ''
    if course_id || last_modified_since
      query_params = '?'
      query_params += "course_id=#{course_id}" if course_id
      query_params += '&' if course_id && last_modified_since
      query_params += "last_modified_since=#{CGI.escape(last_modified_since)}" if last_modified_since 
    end
    # Defined in CourseParticipantInfoService Apex class in Salesforce
    response = get("/services/apexrest/participants/currentandfuture/#{query_params}") 
    JSON.parse(response.body)
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
#    post("/services/apexrest/participants/currentandfuture/", body.to_json, JSON_HEADERS) # Defined in CourseParticipantInfoService apex class in Salesforce
#  end

end
