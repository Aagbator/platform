Rails.application.routes.draw do
  resources :course_contents do
    post :publish
    resources :course_content_histories, path: 'versions', only: [:index, :show]
  end
  resources :file_upload, only: [:create]

  devise_for :users, controllers: { registrations: 'users/registrations', confirmations: 'users/confirmations' }

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

  resources :validations, only: [:index] do
    collection do
      get :report
    end
  end

  root to: "home#welcome"

  # Salesforce Routes
  get 'salesforce/sync_to_lms'
  post 'salesforce/sync_to_lms'


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
