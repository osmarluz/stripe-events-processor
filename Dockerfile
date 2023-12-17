# syntax = docker/dockerfile:1

FROM ruby:3.2.2-slim

# Install packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev pkg-config wait-for-it

# Install application gems
COPY Gemfile* ./
RUN gem update --system && \
    gem install bundler && \
    bundle install

# Create a directory for the app code
RUN mkdir -p /app

# Set working directory
WORKDIR /app
