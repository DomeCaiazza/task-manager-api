require 'rails_helper'

RSpec.describe Api::V1::TasksController, type: :controller do
  let(:user) { create(:user) }
  let(:task) { create(:task, user: user) }
  let(:valid_attributes) { { title: 'Test Task', description: 'Test Description', completed: false } }
  let(:invalid_attributes) { { title: '' } }

  before do
    Rails.application.routes_reloader.execute_unless_loaded
    allow(controller).to receive(:authenticate_devise_api_token!).and_return(true)
    allow(controller).to receive(:current_devise_api_user).and_return(user)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'returns paginated tasks' do
      create_list(:task, 3, user: user)
      get :index, params: { page: 1, per_page: 2 }
      expect(JSON.parse(response.body)['tasks'].length).to eq(2)
      expect(JSON.parse(response.body)['meta']['total_count']).to eq(3)
    end
  end

  describe 'GET #show' do
    it 'returns the requested task' do
      get :show, params: { id: task.id }
      expect(response).to be_successful
      expect(JSON.parse(response.body)['id']).to eq(task.id)
    end

    it 'returns not found for non-existent task' do
      get :show, params: { id: 999999 }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns not found for another user task' do
      other_user = create(:user)
      other_task = create(:task, user: other_user)
      get :show, params: { id: other_task.id }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new task' do
        expect {
          post :create, params: { task: valid_attributes }
        }.to change(Task, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new task' do
        expect {
          post :create, params: { task: invalid_attributes }
        }.not_to change(Task, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { title: 'Updated Task' } }

      it 'updates the requested task' do
        put :update, params: { id: task.id, task: new_attributes }
        task.reload
        expect(task.title).to eq('Updated Task')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity' do
        put :update, params: { id: task.id, task: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it 'returns not found for another user task' do
      other_user = create(:user)
      other_task = create(:task, user: other_user)
      put :update, params: { id: other_task.id, task: valid_attributes }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested task' do
      task_to_destroy = create(:task, user: user)
      expect {
        delete :destroy, params: { id: task_to_destroy.id }
      }.to change(Task, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns not found for another user task' do
      other_user = create(:user)
      other_task = create(:task, user: other_user)
      delete :destroy, params: { id: other_task.id }
      expect(response).to have_http_status(:not_found)
    end
  end
end
