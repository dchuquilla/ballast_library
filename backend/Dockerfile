# Use an official Ruby image as the base
FROM ruby:3.1.2

# Install essential packages and Node.js for Rails assets
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the codebase
COPY . .

# Expose port for Rails server
EXPOSE 3000

COPY entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
