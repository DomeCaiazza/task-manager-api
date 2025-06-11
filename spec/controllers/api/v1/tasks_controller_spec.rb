require 'rails_helper'

RSpec.describe Api::V1::TasksController, type: :controller do
  describe 'GET #index' do
    let!(:tasks) { create_list(:task, 3) }

    it 'returns a successful response' do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it 'returns all tasks with pagination metadata' do
      get :index
      json_response = JSON.parse(response.body)
      expect(json_response['tasks'].length).to eq(3)
      expect(json_response['meta']).to include('current_page', 'total_pages', 'total_count')
    end
  end

  describe 'GET #show' do
    let!(:task) { create(:task) }

    it 'returns the requested task' do
      get :show, params: { id: task.id }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['id']).to eq(task.id)
    end

    it 'returns not found for non-existent task' do
      get :show, params: { id: 999 }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      let(:valid_params) { { task: { title: 'New Task', description: 'Description' } } }

      it 'creates a new task' do
        expect {
          post :create, params: valid_params
        }.to change(Task, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { task: { title: nil } } }

      it 'does not create a new task' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Task, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    let!(:task) { create(:task) }

    context 'with valid parameters' do
      let(:new_attributes) { { task: { title: 'Updated Task' } } }

      it 'updates the task' do
        put :update, params: { id: task.id }.merge(new_attributes)
        task.reload
        expect(task.title).to eq('Updated Task')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_attributes) { { task: { title: nil } } }

      it 'does not update the task' do
        put :update, params: { id: task.id }.merge(invalid_attributes)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:task) { create(:task) }

    it 'destroys the task' do
      expect {
        delete :destroy, params: { id: task.id }
      }.to change(Task, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns not found for non-existent task' do
      delete :destroy, params: { id: 999 }
      expect(response).to have_http_status(:not_found)
    end
  end
end 