FROM ruby:3.3.5-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    nodejs \
    default-mysql-client \
    libmariadb-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy the rest of the application
COPY . .

# Add a script to be executed every time the container starts
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Start the main process
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"] 