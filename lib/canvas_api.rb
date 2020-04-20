require 'rest-client'
#require 'cgi'

class CanvasAPI
  attr_reader :canvas_url

  # Custom HTML to prepend to each body.
  # Note: We add a "new HTML" comment here to flag this page as coming from the
  # new content editor. This is referenced in several places in Canvas code.
  # We also wrap the entire contents in a "bz-module" div, so the CSS selectors
  # work as expected.
  PrependHTML = %q(
    <!-- BRAVEN_NEW_HTML -->
    <div class="bz-module">
  )

  # Custom HTML to append to each body.
  AppendHTML = %q(
    </div>
  )

  def initialize(canvas_url, canvas_token)
    @canvas_url = canvas_url
    @api_url = "#{@canvas_url}/api/v1"
    @global_headers = {
      'Authorization' => "Bearer #{canvas_token}",
    }
  end

  def get(path, params={}, headers={})
    RestClient.get("#{@api_url}#{path}", {params: params}.merge(@global_headers.merge(headers)))
  end

  def post(path, body, headers={})
    RestClient.post("#{@api_url}#{path}", body, @global_headers.merge(headers))
  end

  def put(path, body, headers={})
    RestClient.put("#{@api_url}#{path}", body, @global_headers.merge(headers))
  end

  def delete(path, body={}, headers={})
    # Delete helper method doesn't accept a payload. Have to drop down lower level.
    RestClient::Request.execute(method: :delete, 
      url: "#{@api_url}#{path}", payload: body, headers: @global_headers.merge(headers))
  end

  def update_course_page(course_id, wiki_page_id, wiki_page_body)
    body = {
      'wiki_page[body]' => PrependHTML + wiki_page_body + AppendHTML,
    }

    put("/courses/#{course_id}/pages/#{wiki_page_id}", body)
  end

  def create_user(first_name, last_name, username, email, salesforce_id, student_id, timezone, docusign_template_id=nil)
    body = {
#        'user[name]' => nil, # TODO: this seemed to be null for everyone. figure out if its needed and what it should be set to.
        'user[short_name]' => first_name,
        'user[sortable_name]' => "#{last_name}, #{first_name}",
        'user[skip_registration]' => true,
        'user[time_zone]' => timezone,
        'user[docusign_template_id]' => docusign_template_id,
        'pseudonym[unique_id]' => username,
        'pseudonym[send_confirmation]' => false,
        'communication_channel[type]' => 'email',
        'communication_channel[address]' => email,
        'communication_channel[skip_confirmation]' => true,
        'communication_channel[confirmation_url]' => true,
         # Note: the old code used the Join user.id and not the SF id. But now the user account may not
         # be created yet when we're running Sync To LMS.
        'pseudonym[sis_user_id]' => "BVSFID#{salesforce_id}-SISID#{student_id}" 
    }
    response = post('/accounts/1/users', body)
    JSON.parse(response.body)
  end

  def find_user_in_canvas(email)
    response = get("/accounts/1/users?search_term=#{CGI.escape(email)}")
    users = JSON.parse(response.body)
    users.length == 1 ? users[0] : nil
  end 

  # Returns an array of enrollments objects for the course.
  # See: https://canvas.instructure.com/doc/api/enrollments.html
  # Example Usage:
  #   get_course_enrollments(71, [:StudentEnrollment, :TaEnrollment])
  def get_enrollments(course_id, types=[])
    query_params = "per_page=100"
    types.each_with_index { |t,i| query_params += "&type[]=#{types[i]}"}
    response = get("/courses/#{course_id}/enrollments?#{query_params}")
    get_all_from_pagination(response)
  end

  # Enrolls the user in the new course, without modifying any existing data
  def enroll_user_in_course(canvas_user_id, course_id, canvas_role, section_id)
    body = {
      'enrollment[user_id]' => canvas_user_id,
      'enrollment[type]' => canvas_role,
      'enrollment[enrollment_state]' => 'active',
      'enrollment[limit_privileges_to_course_section]' => true,
      'enrollment[notify]' => false,
      'enrollment[course_section_id]' => section_id
    }
    post("/courses/#{course_id}/enrollments", body)
  end

  # See: https://canvas.instructure.com/doc/api/enrollments.html#method.enrollments_api.destroy
  # Valid values for task:
  #   conclude, delete,  deactivate
  #
  # Note: when deleting their enrollment and then re-enrolling them, it doesn't appear to lose
  # any data (like magic fields or submissions)
  def cancel_enrollment(enrollment, task='delete')
    response = delete("/courses/#{enrollment['course_id']}/enrollments/#{enrollment['id']}", {'task' => task})
    JSON.parse(response.body)
  end

  def get_sections(course_id)
    response = get("/courses/#{course_id}/sections?per_page=100")
    get_all_from_pagination(response)
  end

  def create_section(course_id, section_name)
    response = post("/courses/#{course_id}/sections", {'course_section[name]' => section_name})
    JSON.parse(response.body)
  end

  # See: https://canvas.instructure.com/doc/api/file.pagination.html
  def get_all_from_pagination(response)
    info = JSON.parse(response.body)
    while response
      link = response.headers[:link]
      break if link.nil?

      next_url = nil
      link.split(',').each do |part|
        if part.ends_with?('; rel="next"')
          next_url = part[1 .. link.index('>')-1]
          break
        end
      end

      if next_url
        # Turn something like this: https://portal.bebraven.org/api/v1/courses/71/enrollments?page=2&per_page=100
        # into this: /courses/71/enrollments?page=2&per_page=100
        # So that we can use the get() convenience method in case we ever add centralized logic / error handling there.
        next_url.sub!(/^.*api\/v1/, '')
        response = get(next_url)
        more_info = JSON.parse(response.body)
        info.concat(more_info)
      else
        response = nil
      end
    end

    info
  end

end
