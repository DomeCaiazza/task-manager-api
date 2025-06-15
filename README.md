# Task Manager API

A RESTful API for task management, developed with Ruby on Rails, that allows each user to manage their activities independently.

[Go to italian version](README.IT.md)

## Requirements

- Docker and Docker Compose
- Postman

## Environment Setup

### Environment Variables

In the project root, copy or move the `.env_sample` file to `.env`. The variables it contains are:

```env
APPLICATION_NAME="task_manager"
MYSQL_HOST_APP="db-app"
MYSQL_HOST_TEST="db-test"

MYSQL_USER="task_manager"
MYSQL_PASSWORD="password"
MYSQL_PORT="3306"
MYSQL_ROOT_PASSWORD="password"

RAILS_ENV="development"

RAILS_MASTER_KEY="6d93e4e8e4ec7e2d1b4128651a19d619" ## this is an example, don't user it in production please see https://rubyonrails.org/docs
SECRET_KEY_BASE="f2e4f2a4bd502d7a74342e95826cd37b72cca93b23bed1330d556bb0e63d0e506c2bbcb17d7f3a653339d93c37ecb2f4e2617b65772ee0e957b50a97d26224ff" ## this is an example, don't user it in production please see https://rubyonrails.org/docs
```

### Docker Installation

After this procedure, the application will be served locally at: http://localhost:3000

1. Clone the repository:
```bash
git clone https://github.com/DomeCaiazza/task-manager-api.git
cd task-manager-api
```

2. Create the `.env` environment variables file as shown above

3. Start Docker containers:
```bash
docker-compose up --build -d && docker-compose logs -tf
```

4. (Optional) In a new terminal, run database migrations:
PS: database creation and migration is automatically performed by the "entrypoint.dev.sh" file
```bash
docker-compose exec web-app bundle exec rails db:create db:migrate
```

5. (Optional) Populate the database with sample data:
```bash
docker-compose exec web-app bundle exec rails db:seed
```

## Running Tests

Development and test databases are separate, in docker-compose two distinct services are defined, the test database is mounted in RAM to improve performance.

To run the tests:

```bash
docker-compose exec web-app bundle exec rspec
```

## Documentation

The OpenAPI documentation is automatically generated during container startup through the entrypoint script. You can access the interactive documentation at:

```
http://localhost:3000/api-docs/index.html
```

This documentation provides a description of all available endpoints, including required parameters, expected responses, and usage examples.

## API Structure

### Postman
To test this application, import the file https://raw.githubusercontent.com/DomeCaiazza/task-manager-api/refs/heads/main/task-manager-api.postman_collection.json into your Postman

The environment variables are defined within the collection.

#### Authentication for API calls
In the "task-manager-api" collection, the "token" variable is defined which should be populated with the response token after authentication from the `/users/tokens/sign_in` route

### Available Endpoints

#### Authentication
- POST `/users/tokens/sign_in` - Login
- POST `/users/tokens/sign_up` - Registration
- POST `/users/tokens/revoke` - Revoke token
- GET `/users/tokens/info` - User info

#### Tasks
- GET `/api/v1/tasks` - List tasks
- GET `/api/v1/tasks/:id` - Task details
- POST `/api/v1/tasks` - Create a new task
- PUT/PATCH `/api/v1/tasks/:id` - Update a task
- DELETE `/api/v1/tasks/:id` - Delete a task

### Task Parameters
- `title` (string, required)
- `description` (text)
- `completed` (boolean)

### Filters
The task list endpoint allows filtering results by all its parameters, available filters are:
- completed_eq: completion equals "true" or "false"
- title_cont: title contains
- description_cont: description contains
- title_or_description_cont: title or description contains

## Development

### Project Structure
- `app/controllers/api/v1/` - API Controllers
- `app/models/` - Models
- `spec/` - RSpec Tests

### Useful Commands

- Start the server:
```bash
docker-compose up
```

- Run migrations:
```bash
docker-compose exec web-app bundle exec rails db:migrate
```

- Open Rails console:
```bash
docker-compose exec web-app bundle exec rails console
```

- Check docker compose logs in real-time:
```bash
docker-compose logs -tf
```

- Generate open api documentation (doesn't work in production environment)
```bash
docker-compose exec web-app rake rswag:specs:swaggerize
```

## Security

- The API uses Devise API for authentication
- All API requests, except registration and login, require authentication
- Passwords are validated with a minimum of 6 characters 