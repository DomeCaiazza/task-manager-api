require 'swagger_helper'
RSpec.describe 'User Authentication API', type: :request do
  path '/users/tokens/sign_up' do
    post 'Register a new user' do
      tags 'Users'
      description 'Create a new user account'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string, format: :password }
            },
            required: [ 'email', 'password' ]
          }
        }
      }

      response '200', 'User registered successfully' do
        let(:user) { { user: { email: 'test@example.com', password: 'password123', password_confirmation: 'password123' } } }

        schema type: :object,
          properties: {
            id: { type: :integer },
            email: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }

        run_test!
      end

      response '422', 'Invalid user data' do
        let(:user) { { user: { email: 'invalid_email', password: 'short', password_confirmation: 'short' } } }
        run_test!
      end
    end
  end

  path '/users/tokens/sign_in' do
    post 'Sign in user' do
      tags 'Users'
      description 'Authenticate user and return access token'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string, format: :password }
            },
            required: [ 'email', 'password' ]
          }
        }
      }

      response '200', 'User signed in successfully' do
        let(:user) { create(:user) }
        let(:user_params) { { user: { email: user.email, password: 'password123' } } }

        schema type: :object,
          properties: {
            id: { type: :integer },
            email: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }

        run_test!
      end

      response '401', 'Invalid credentials' do
        let(:user_params) { { user: { email: 'wrong@example.com', password: 'wrongpassword' } } }
        run_test!
      end
    end
  end

  path '/users/tokens/revoke' do
    post 'Sign out user' do
      tags 'Users'
      description 'Revoke user access token'
      security [ bearer_auth: [] ]

      response '200', 'User signed out successfully' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_new_token}" }
        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end

  path '/users/tokens/info' do
    get 'Get user info' do
      tags 'Users'
      description 'Retrieve current user information'
      security [ bearer_auth: [] ]

      response '200', 'User info retrieved successfully' do
        let(:user) { create(:user) }
        let(:Authorization) { "Bearer #{user.generate_new_token}" }

        schema type: :object,
          properties: {
            id: { type: :integer },
            email: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }

        examples 'application/json' => {
          id: 1,
          email: 'user@example.com',
          created_at: '2024-03-20T10:00:00Z',
          updated_at: '2024-03-20T10:00:00Z'
        }

        run_test!
      end

      response '401', 'Unauthorized' do
        let(:Authorization) { nil }
        run_test!
      end
    end
  end
end
