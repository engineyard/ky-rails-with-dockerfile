FROM ruby:2.4.0-alpine
RUN apk update && apk add nodejs build-base libxml2-dev libxslt-dev postgresql postgresql-dev sqlite sqlite-dev busybox-suid curl


# Configure the main working directory. This is the base 
# directory used in any further RUN, COPY, and ENTRYPOINT 
# commands.
RUN mkdir -p /app 
WORKDIR /app

# Copy the Gemfile as well as the Gemfile.lock and install 
# the RubyGems. This is a separate step so the dependencies 
# will be cached unless changes to one of those two files 
# are made.
COPY Gemfile Gemfile.lock ./ 
RUN gem install bundler && bundle install --without development test --jobs 20 --retry 5

# Set environment to production
ENV RAILS_ENV development 
ENV RACK_ENV development

# Copy the main application.
COPY . ./

# Copy config/database.yml.prod to config/database.yml
#COPY config/database.yml.prod config/database.yml

# Precompile Rails assets
RUN bundle exec rake assets:precompile

# Expose port 3000 to the Docker host, so we can access it 
# from the outside.
EXPOSE 3000

# The main command to run when the container starts. Also 
# tell the Rails dev server to bind to all interfaces by 
# default.
ENTRYPOINT ["bundle", "exec", "rails", "server", "-e", "development"]
