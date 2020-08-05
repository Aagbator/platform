require 'lti_advantage_api'
require 'lti_score'
require 'uri'

# PS: A project submission is a nested resource under a user/student
# JESS: Pretend this is a project submission
# Every project submission has a student and a project version
# For now, that's a student_id and course_content_history_version
class CourseContentHistoriesController < ApplicationController
  include DryCrud::Controllers::Nestable
  nested_resource_of CourseContent
  layout 'content_editor'

  before_action :set_course_content
  before_action :set_lti_launch, only: [:new, :create]

  def index
    # PS: TA & Students
    # All submissions for a student for a project (all versions)
    # This goes away when we nest this resource under student
    # params.require([:student_id])
    # TODO: Render all submissions for the student
  end

  def show
    unless params[:state].present?
      @body_with_user_inputs = @course_content_history.body
      return
    end

    # PS: TA & Students
    # Renders a particular project submission read-only
    # Needs to fetch the version of the project, read the submission data from LRS
    # and populate the project with those answers


    # This shows a project submission for this version of the course_contents, the one
    # associated with a project when inserted into Canvas through the LTI extension. It does this
    # by loading the HTML with user input fields (aka data-bz-retained) highlighted, disabled (readonly),
    # and populated with the student's answers when they submitted it.
    #
    # TODO: Long term, a project will use the Project model and store the snapshot of the html there or maybe have a ProjectContent
    # model to hold it. But in order to get a demo going and not deal with the complexity of filling out the whole course/org/role/project/project_submission
    # data model, we're just doing the dumb thing for now. These histories aren't currently used by any end-user.
    params.require([:student_id, :course_content_id, :state])

    # TODO: make sure the currently logged in user has access to view the submission for this student_id.
    # Must be the student themselves or a TA or staff who has access. Need to use Canvas roles to check.
    # Task: https://app.asana.com/0/1174274412967132/1185569091008475    
    launch = LtiLaunch.current(params[:state])
    @project_lti_id = launch.activity_id
    # PS: Ryan is moving this to JS
    @body_with_user_inputs = helpers.project_submission_html_for(@project_lti_id, @course_content_history.body, User.find(params[:student_id]))
  end

  # PS: Both new and edit have the same form with a button that goes to create
  def new
    # TODO: Authentication that this is a student
    @student = User.find(current_user.id)
    @project_lti_id = @lti_launch.activity_id

    previous_submission_data = helpers.fetch_user_data_for(
      @lti_launch.activity_id,
      @student,
    )

    @authenticity_token = params[:authenticity_token]

    if previous_submission_data.empty? 
      # Just return the body of the project, nothing filled out
      @body_with_user_inputs = @course_content.last_version.body
    else
      # Pre-populate with previous submission
      # FIXME: This re-fetches
      @body_with_user_inputs = helpers.project_submission_html_for(
        @lti_launch.activity_id,
        @course_content.last_version.body,
        @student,
        true, # Enable writes
      )
    end

    # Submit button => Create (in erb)
  end

  # TODO: https://app.asana.com/0/1174274412967132/1186960110311121
  # PS: Should we change routes.rb to configure POST -> some other name like "Submit"?
  def create
    # PS: Students only
    # Puts an entry in LTI so Canvas knows there's been a submission
    params.require([:state, :course_content_id]) 

    # TODO: student opens assignment // designer publishes new assignment // student submits
    # now the version is bad, we need the version passed in from #new
    submission_url = Addressable::URI.parse(course_content_course_content_history_url(
      @course_content,
      @course_content.last_version,
    ))
    submission_url.query = { student_id: current_user.id }.to_query

    lti_launch = LtiLaunch.current(params[:state])
    lti_score = LtiScore.new_project_submission(current_user.canvas_id, submission_url.to_s)
    LtiAdvantageAPI.new(lti_launch).create_score(lti_score)

    # FIXME: redirect :new doesn't work for nested resources?
    redirect_to new_course_content_course_content_history_url(
      [@course_content, @course_content.last_version],
      state: params[:state],
    )
  end

  private
    def set_lti_launch
      @lti_launch = LtiLaunch.current(params[:state])
    end

    def set_course_content
      @course_content = CourseContent.find(params[:course_content_id])
    end
end
