require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
#
# Also compared to earlier versions of this generator, there are no longer any
# expectations of assigns and templates rendered. These features have been
# removed from Rails core in Rails 5, but can be added back in via the
# `rails-controller-testing` gem.

RSpec.describe UsersController, type: :controller do
  render_views
  
  let(:user) { create :admin_user }

  # This should return the minimal set of attributes required to create a valid
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { attributes_for(:user) }

  let(:invalid_attributes) {
    {name: user.name }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  let(:valid_session) { {} }
  
  describe 'when logged in' do
    before do
      sign_in user
    end

    describe "GET #index" do
      it "returns a success response" do
        get :index, params: {}, session: valid_session
        expect(response).to be_successful
      end
    end
  end
  
  describe 'JSON requests' do
    let(:access_token) { create :access_token }
    
    describe "GET #index" do
      it "allows access token via params" do
        get :index, params: {access_key: access_token.key}, session: valid_session, format: :json
        expect(response).to be_successful
      end

      it "allows access token via headers" do
        request.headers.merge!('Access-Key' => access_token.key)
        
        get :index, params: {}, session: valid_session, format: :json
        expect(response).to be_successful
      end
    end
  end
end
