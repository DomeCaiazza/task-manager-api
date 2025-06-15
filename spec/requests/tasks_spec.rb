require 'swagger_helper'
RSpec.describe 'Task manager API', type: :request, rswag: true do
  # All endpoints require Bearer token authentication
  # If no valid token is provided, a 401 Unauthorized response will be returned
  # Format: Authorization: Bearer <token>

  path '/api/v1/tasks' do
    get 'List tasks' do
      tags 'Tasks'
      description 'Retrieve a paginated list of tasks. Supports filtering and sorting by various fields. Requires Bearer token authentication.'
      security [ bearer_auth: [] ]

      parameter name: :page, in: :query, type: :integer, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, description: 'Number of items per page'
      parameter name: :'q[title_cont]', in: :query, type: :string, description: 'Filter by title containing'
      parameter name: :'q[description_cont]', in: :query, type: :string, description: 'Filter by description containing'
      parameter name: :'q[title_or_description_cont]', in: :query, type: :string, description: 'Filter by title or description containing'
      parameter name: :'q[completed_eq]', in: :query, type: :boolean, description: 'Filter by completion status', example: [ "true", "false" ]

      response '200', 'Tasks list retrieved successfully' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_new_token}" }
        let(:tasks) { create_list(:task, 3, user: user) }
        let(:page) { 1 }
        let(:per_page) { 10 }
        let(:'q[title_cont]') { nil }
        let(:'q[description_cont]') { nil }
        let(:'q[title_or_description_cont]') { nil }
        let(:'q[completed_eq]') { nil }

        before { tasks }

        let(:task_schema) do
          {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              description: { type: :string },
              completed: { type: :boolean },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          }
        end

        schema type: :object,
          properties: {
            tasks: {
              type: :array,
              items: { '$ref' => '#/components/schemas/task' }
            },
            meta: {
              type: :object,
              properties: {
                current_page: { type: :integer },
                total_pages: { type: :integer },
                total_count: { type: :integer }
              }
            }
          }

        run_test!
      end

      response '401', 'Unauthorized - Bearer token is required' do
        let(:Authorization) { nil }
        run_test!
      end

      response '404', 'Not found' do
        run_test!
      end
    end


    post 'Create a new task' do
      tags 'Tasks'
      description 'Add a new task for user. Requires Bearer token authentication.'
      security [ bearer_auth: [] ]
      consumes 'application/json'
      parameter name: :task, in: :body, schema: {
        type: :object,
        properties: {
          task: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              completed: { type: :boolean }
            },
            required: [ 'title' ]
          }
        }
      }

      response '201', 'Task created successfully' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_new_token}" }
        let(:task) { { task: { title: 'New Task', description: 'Task description', completed: false } } }

        schema type: :object,
          properties: {
            id: { type: :integer },
            title: { type: :string },
            description: { type: :string },
            completed: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }

        run_test!
      end

      response '422', 'Invalid task' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_new_token}" }
        let(:task) { { task: { title: '' } } }
        run_test!
      end

      response '401', 'Unauthorized - Bearer token is required' do
        let(:Authorization) { nil }
        let(:task) { { task: { title: 'New Task' } } }
        run_test!
      end
    end
  end

  path '/api/v1/tasks/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Retrieve a specific task' do
      tags 'Tasks'
      description 'Get details of a specific task. Requires Bearer token authentication.'
      security [ bearer_auth: [] ]

      response '200', 'Task found' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_new_token}" }
        let(:task) { create(:task, user: user) }
        let(:id) { task.id }

        schema type: :object,
          properties: {
            id: { type: :integer },
            title: { type: :string },
            description: { type: :string },
            completed: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }

        run_test!
      end

      response '404', 'Task not found' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_new_token}" }
        let(:id) { 999999 }
        run_test!
      end

      response '401', 'Unauthorized - Bearer token is required' do
        let(:Authorization) { nil }
        let(:id) { 1 }
        run_test!
      end
    end

    put 'Update a task' do
      tags 'Tasks'
      description 'Modify an existent task. Requires Bearer token authentication.'
      security [ bearer_auth: [] ]
      consumes 'application/json'
      parameter name: :task, in: :body, schema: {
        type: :object,
        properties: {
          task: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              completed: { type: :boolean }
            }
          }
        }
      }

      response '200', 'Task updated successfully' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_new_token}" }
        let(:task) { create(:task, user: user) }
        let(:id) { task.id }
        let(:task_params) { { task: { title: 'Updated Task' } } }

        schema type: :object,
          properties: {
            id: { type: :integer },
            title: { type: :string },
            description: { type: :string },
            completed: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }

        run_test!
      end

      response '422', 'Invalid task' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_new_token}" }
        let(:task) { create(:task, user: user) }
        let(:id) { task.id }
        let(:task_params) { { task: { title: '' } } }
        run_test!
      end

      response '404', 'Task not found' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_new_token}" }
        let(:id) { 999999 }
        let(:task_params) { { task: { title: 'Updated Task' } } }
        run_test!
      end

      response '401', 'Unauthorized - Bearer token is required' do
        let(:Authorization) { nil }
        let(:id) { 1 }
        let(:task_params) { { task: { title: 'Updated Task' } } }
        run_test!
      end
    end

    delete 'Delete a task' do
      tags 'Tasks'
      description 'Delete a task. Requires Bearer token authentication.'
      security [ bearer_auth: [] ]

      response '204', 'Task deleted successfully' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_new_token}" }
        let(:task) { create(:task, user: user) }
        let(:id) { task.id }
        run_test!
      end

      response '404', 'Task not found' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_new_token}" }
        let(:id) { 999999 }
        run_test!
      end

      response '401', 'Unauthorized - Bearer token is required' do
        let(:Authorization) { nil }
        let(:id) { 1 }
        run_test!
      end
    end
  end
end
