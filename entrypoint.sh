#!/bin/bash -i

# Remove a potentially pre-existing server.pid for Rails.
rm -rf /app/tmp/pids/server.pid

# Checks if the dependencies listed in Gemfile are satisfied by currently installed gems
bundle clean --force

# Check whether or not gems are installed, and install it in case they're not.
bundle check || bundle install

wait-for-it postgres:5432 -- "$@"
