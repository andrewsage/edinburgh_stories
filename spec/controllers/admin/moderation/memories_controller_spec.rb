require 'rails_helper'

describe Admin::Moderation::MemoriesController do
  let(:memory) { Fabricate.build(:photo_memory, id: 123) }

  before :each do
    allow(Memory).to receive(:find).with(memory.to_param).and_return(memory)
  end

  it 'requires the user to be authenticated as an administrator' do
    expect(subject).to be_a(Admin::AuthenticatedAdminController)
  end

  describe 'PUT approve' do
    context 'when not logged in' do
      it 'redirects to sign in' do
        put :approve, id: memory.id
        expect(response).to redirect_to(signin_path)
      end
    end

    context 'when logged in but not as an admin' do
      it 'redirects to sign in' do
        @user = Fabricate(:active_user)
        login_user
        put :approve, id: memory.id
        expect(response).to redirect_to(signin_path)
      end
    end

    context 'when logged in' do
      let(:result)          { true }
      let(:format)          { 'html' }
      let(:previous_state)  { 'unmoderated' }

      before :each do
        @user = Fabricate(:admin_user)
        login_user
        allow(memory).to receive(:approve!).and_return(result)
        allow(memory).to receive(:previous_state).and_return(previous_state)
        put :approve, id: memory.id, format: format
      end

      it 'looks for the memory to approve' do
        expect(Memory).to have_received(:find).with(memory.to_param)
      end

      context "when memory is found" do
        it "updates the memory's status to 'Approved'" do
          expect(memory).to have_received(:approve!)
        end

        context 'when an HTML  request' do
          let(:format) { 'html' }

          context 'when original state was "unmoderated"' do
            let(:previous_state) { 'unmoderated' }

            it 'redirects to the unmoderated index page' do
              expect(response).to redirect_to(admin_unmoderated_path)
            end
          end

          context 'when original state was not "unmoderated"' do
            let(:previous_state) { 'approved' }

            it 'redirects to the moderated index page' do
              expect(response).to redirect_to(admin_moderated_path)
            end
          end

          context "when successful" do
            let(:result) { true }

            it "displays a success message" do
              expect(flash[:notice]).to eql('Memory approved')
            end
          end

          context "when unsuccessful" do
            let(:result) { false }

            it "displays a failure alert" do
              expect(flash[:alert]).to eql('Could not approve memory')
            end
          end
        end

        context 'when a JSON request' do
          let(:format) { 'json' }

          context "when successful" do
            let(:result) { true }

            it 'provides a JSON version of the memory' do
              expect(response.body).to eql(memory.to_json)
            end
          end

          context "when unsuccessful" do
            let(:result) { false }

            it "returns an Unprocessable Entity error" do
              expect(response.status).to eql(422)
              expect(response.body).to eql('Unable to approve')
            end
          end
        end
      end
    end
  end

  describe 'PUT reject' do
    let(:reason) { 'unsuitable' }
    let(:result) { true }
    let(:format) { 'html' }

    context 'when not logged in' do
      it 'redirects to sign in' do
        put :reject, id: memory.id, reason: reason
        expect(response).to redirect_to(signin_path)
      end
    end

    context 'when logged in but not as an admin' do
      it 'redirects to sign in' do
        @user = Fabricate(:active_user)
        login_user
        put :reject, id: memory.id, reason: reason
        expect(response).to redirect_to(signin_path)
      end
    end

    context 'when logged in' do
      let(:previous_state)  { 'unmoderated' }

      before :each do
        @user = Fabricate(:admin_user)
        login_user
        allow(memory).to receive(:reject!).and_return(result)
        allow(memory).to receive(:previous_state).and_return(previous_state)
        put :reject, id: memory.id, reason: reason, format: format
      end

      it 'looks for the memory to reject' do
        expect(Memory).to have_received(:find).with(memory.to_param)
      end

      context "when memory is found" do
        it "updates the memory's status to 'Rejected'" do
          expect(memory).to have_received(:reject!).with('unsuitable')
        end

        context 'when an HTML  request' do
          let(:format) { 'html' }

          context 'when original state was "unmoderated"' do
            let(:previous_state) { 'unmoderated' }

            it 'redirects to the unmoderated index page' do
              expect(response).to redirect_to(admin_unmoderated_path)
            end
          end

          context 'when original state was not "unmoderated"' do
            let(:previous_state) { 'approved' }

            it 'redirects to the moderated index page' do
              expect(response).to redirect_to(admin_moderated_path)
            end
          end

          context "when successful" do
            let(:result) { true }

            it "displays a success message" do
              expect(flash[:notice]).to eql('Memory rejected')
            end
          end

          context "when unsuccessful" do
            let(:result) { false }

            it "displays a failure alert" do
              expect(flash[:alert]).to eql('Could not reject memory')
            end
          end
        end

        context 'when a JSON request' do
          let(:format) { 'json' }

          context "when successful" do
            let(:result) { true }

            it 'provides a JSON version of the memory' do
              expect(response.body).to eql(memory.to_json)
            end
          end

          context "when unsuccessful" do
            let(:result) { false }

            it "returns an Unprocessable Entity error" do
              expect(response.status).to eql(422)
              expect(response.body).to eql('Unable to reject')
            end
          end
        end
      end
    end
  end

  describe 'PUT unmoderate' do
    let(:result) { true }
    let(:format) { 'html' }

    context 'when not logged in' do
      it 'redirects to sign in' do
        put :unmoderate, id: memory.id
        expect(response).to redirect_to(signin_path)
      end
    end

    context 'when logged in but not as an admin' do
      it 'redirects to sign in' do
        @user = Fabricate(:active_user)
        login_user
        put :unmoderate, id: memory.id
        expect(response).to redirect_to(signin_path)
      end
    end

    context 'when logged in' do
      let(:previous_state)  { 'unmoderated' }

      before :each do
        @user = Fabricate(:admin_user)
        login_user
        allow(memory).to receive(:unmoderate!).and_return(result)
        allow(memory).to receive(:previous_state).and_return(previous_state)
        put :unmoderate, id: memory.id, format: format
      end

      it 'looks for the memory to unmoderate' do
        expect(Memory).to have_received(:find).with(memory.to_param)
      end

      context "when memory is found" do
        it "updates the memory's status to 'Unmoderated'" do
          expect(memory).to have_received(:unmoderate!)
        end

        context 'when an HTML  request' do
          let(:format) { 'html' }

          context 'when original state was "unmoderated"' do
            let(:previous_state) { 'unmoderated' }

            it 'redirects to the unmoderated index page' do
              expect(response).to redirect_to(admin_unmoderated_path)
            end
          end

          context 'when original state was not "unmoderated"' do
            let(:previous_state) { 'approved' }

            it 'redirects to the moderated index page' do
              expect(response).to redirect_to(admin_moderated_path)
            end
          end

          context "when successful" do
            let(:result) { true }

            it "displays a success message" do
              expect(flash[:notice]).to eql('Memory unmoderated')
            end
          end

          context "when unsuccessful" do
            let(:result) { false }

            it "displays a failure alert" do
              expect(flash[:alert]).to eql('Could not unmoderate memory')
            end
          end
        end

        context 'when a JSON request' do
          let(:format) { 'json' }

          context "when successful" do
            let(:result) { true }

            it 'provides a JSON version of the memory' do
              expect(response.body).to eql(memory.to_json)
            end
          end

          context "when unsuccessful" do
            let(:result) { false }

            it "returns an Unprocessable Entity error" do
              expect(response.status).to eql(422)
              expect(response.body).to eql('Unable to unmoderate')
            end
          end
        end
      end
    end
  end
end

