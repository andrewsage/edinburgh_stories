require 'rails_helper'

class ProtectedController < My::AuthenticatedUserController; end

describe My::AuthenticatedUserController do
  controller ProtectedController do
    skip_before_action :require_login, only: [:index]

    def index
      render text: 'index'
    end

    def secret
      render text: 'show'
    end
  end

  describe 'authentication' do
    context 'authenticates pages by default' do
      before :each do
        routes.draw { get 'secret' => 'protected#secret' }
        get :secret
      end

      it "redirects to the login page" do
        expect(response).to redirect_to(:login)
      end

      it "alerts the user to log in" do
        expect(flash[:alert]).to eql('Please login first')
      end
    end

    it 'ignores any pages marked as unauthenticated' do
      get :index
      expect(response).to be_success
    end
  end
end
