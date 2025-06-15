#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Install gems
bundle install

rails db:create
rails db:migrate

if [ "$RAILS_ENV" == "development" ]; then
    RUN_RSWAG=true rake rswag:specs:swaggerize
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile)
exec "$@"
