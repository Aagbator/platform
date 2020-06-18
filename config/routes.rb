Rails.application.routes.draw do

  resources :course_contents do
    post :publish
    resources :course_content_histories, path: 'versions', only: [:index, :show]
  end
  resources :file_upload, only: [:create]

  devise_for :users, controllers: { registrations: 'users/registrations', confirmations: 'users/confirmations', passwords: 'users/passwords' }

  devise_scope :user do
    get 'users/password/check_email', to: "users/passwords#check_email"
    get 'users/registration', to: "users/registrations#show"
  end

  get 'home/welcome'

  resources :industries, except: [:show]
  resources :interests, except: [:show]
  resources :locations, only: [:index, :show]
  resources :majors, except: [:show]

  resources :programs

  # See this for why we nest things only 1 deep:
  # http://weblog.jamisbuck.org/2007/2/5/nesting-resources

  resources :courses, only: [:index, :show] do
    resources :grade_categories, only: [:index, :show]
    resources :projects, only: [:index, :show]
    resources :lessons, only: [:index, :show]
  end

  resources :grade_categories, only: [:index, :show] do
    resources :projects, only: [:index, :show]
    resources :lessons, only: [:index, :show]
  end

  resources :projects, only: [:index, :show] do
    resources :project_submissions, only: [:index, :show], :path => 'submissions'
  end
  resources :lessons, only: [:index, :show] do
    resources :lesson_submissions, only: [:index, :show], :path => 'submissions'
  end

  resources :roles, except: [:show]
  resources :users, only: [:index, :show]

  resources :postal_codes, only: [:index, :show] do
    collection do
      get :distance
      post :search
    end
  end

  resources :access_tokens, except: [:show]

  # Helps with implementing any JWK authentication or encryption flows.
  resources :keypairs, only: :index, format: :j

  resources :validations, only: [:index] do
    collection do
      get :report
    end
  end

  root to: "home#welcome"

  # Salesforce Routes
  get 'salesforce/sync_to_lms'
  post 'salesforce/sync_to_lms'

  # Canvas LTI extension routes

# TODO: whatever "placements" we decide to implement, create controllers and views for each.
#  resources :lti_editor_button, only: [:index, :create]         # https://canvas.instructure.com/doc/api/file.editor_button_placement.html
#  resources :lti_link_selection, only: [:index, :create]        # https://canvas.instructure.com/doc/api/file.link_selection_placement.html
#  resources :lti_homework_submission, only: [:index, :create]   # https://canvas.instructure.com/doc/api/file.homework_submission_tools.html
#  resources :lti_course_navigation, only: [:index, :create]     # https://canvas.instructure.com/doc/api/file.navigation_tools.html
#  resources :lti_account_navigation, only: [:index, :create]    # https://canvas.instructure.com/doc/api/file.navigation_tools.html
#  resources :lti_user_navigation, only: [:index, :create]        # https://canvas.instructure.com/doc/api/file.navigation_tools.html
#  resources :lti_assignment_selection, only: [:index, :create]     # https://canvas.instructure.com/doc/api/file.assignment_selection_placement.html
#  resources :lti_resource_selection, only: [:index, :create]     # Steps 3 and 4 of this flow: https://canvas.instructure.com/doc/api/file.assignment_selection_placement.html

  # LTI proof of concept routes. Clean these up.
  resources :lti_poc, only: [:index, :create]
  post '/lti/login', to: 'lti_launch#login'
  get '/lti/launch', to: 'lti_launch#launch'
  post '/lti/launch', to: 'lti_launch#launch'
  post '/lti/deep_link', to: 'lti_launch#deep_link_response'
  get '/lti/rise360_launch', to: 'lti_launch#rise360_launch'
  post '/lti/rise360_launch', to: 'lti_launch#rise360_launch'

  # RubyCAS Routes
  resources :cas, except: [:show]
  get '/cas/login', to: 'cas#login'
  post '/cas/login', to: 'cas#loginpost'
  get '/cas/logout', to: 'cas#logout'
  get '/cas/loginTicket', to: 'cas#loginTicket'
  post '/cas/loginTicket', to: 'cas#loginTicketPost'
  get '/cas/validate', to: 'cas#validate'
  get '/cas/serviceValidate', to: 'cas#serviceValidate'
  get '/cas/proxyValidate', to: 'cas#proxyValidate'
  get '/cas/proxy', to: 'cas#proxy'

end
