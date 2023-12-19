# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.2'

gem 'aasm', '~> 5.5'
gem 'bootsnap', require: false
gem 'dry-monads', '~> 1.6'
gem 'pg', '~> 1.5', '>= 1.5.4'
gem 'puma', '~> 6.4'
gem 'rails', '~> 7.1.2'
gem 'responders', '~> 3.1', '>= 3.1.1'
gem 'stripe', '~> 10.3'
gem 'tzinfo-data', platforms: %i[windows jruby]

group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :test do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
end
