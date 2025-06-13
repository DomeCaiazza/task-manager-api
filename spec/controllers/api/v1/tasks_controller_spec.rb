require 'rails_helper'

RSpec.describe Api::V1::TasksController, type: :controller do
  let(:user) { create(:user) }
  let(:task) { create(:task, user: user) }
  let(:valid_attributes) { { title: 'Test Task', description: 'Test Description', completed: false } }
  let(:invalid_attributes) { { title: '' } }

  before do
    Rails.application.routes_reloader.execute_unless_loaded
    sign_in(user)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index, params: { user_id: user.id }
      expect(response).to be_successful
    end

    it 'returns paginated tasks' do
      create_list(:task, 3, user: user)
      get :index, params: { user_id: user.id, page: 1, per_page: 2 }
      expect(JSON.parse(response.body)['tasks'].length).to eq(2)
      expect(JSON.parse(response.body)['meta']['total_count']).to eq(3)
    end
  end

  describe 'GET #show' do
    it 'returns the requested task' do
      get :show, params: { user_id: user.id, id: task.id }
      expect(response).to be_successful
      expect(JSON.parse(response.body)['id']).to eq(task.id)
    end

    it 'returns not found for non-existent task' do
      get :show, params: { user_id: user.id, id: 999999 }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns unauthorized for another user task' do
      other_user = create(:user)
      other_task = create(:task, user: other_user)
      get :show, params: { user_id: other_user.id, id: other_task.id }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new task' do
        expect {
          post :create, params: { user_id: user.id, task: valid_attributes }
        }.to change(Task, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new task' do
        expect {
          post :create, params: { user_id: user.id, task: invalid_attributes }
        }.not_to change(Task, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid parameters' do
      let(:new_attributes) { { title: 'Updated Task' } }

      it 'updates the requested task' do
        put :update, params: { user_id: user.id, id: task.id, task: new_attributes }
        task.reload
        expect(task.title).to eq('Updated Task')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid parameters' do
      it 'returns unprocessable entity' do
        put :update, params: { user_id: user.id, id: task.id, task: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it 'returns unauthorized for another user task' do
      other_user = create(:user)
      other_task = create(:task, user: other_user)
      put :update, params: { user_id: other_user.id, id: other_task.id, task: valid_attributes }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested task' do
      task_to_destroy = create(:task, user: user)
      expect {
        delete :destroy, params: { user_id: user.id, id: task_to_destroy.id }
      }.to change(Task, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns unauthorized for another user task' do
      other_user = create(:user)
      other_task = create(:task, user: other_user)
      delete :destroy, params: { user_id: other_user.id, id: other_task.id }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
