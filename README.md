# webhooks-processor
A simple Ruby on Rails application that receives and processes webhooks, with a concrete Stripe example.

![ruby](https://img.shields.io/badge/Ruby-3.2.2-green.svg)
![rails](https://img.shields.io/badge/Rails-7.1.2-green.svg)

## Project Walkthrough

### Services

We have 2 sets of services on this project:
  - One set to retrieve authorization and processing for the configured webhooks:
    - `Webhooks::AuthorizatorRetriever`
    - `Webhooks::ProcessorRetriever`
  - Another set to handle the authorization and processing of each specific webhook. We have Stripe set up on this project:
    - `Webhooks::Authorizators::Stripe`
    - The class `Webhooks::Processors::Stripe` directs the handling of each supported event to specific classes:
      - `Webhooks::Processors::Stripe::SubscriptionCreator`
      - `Webhooks::Processors::Stripe::SubscriptionCanceler`
      - `Webhooks::Processors::Stripe::SubscriptionPayer`

All these classes use the resources provided in the `dry-monads` gem to handle return values.

The logic involved with processing the events is pretty simple, so I decided not to do it asynchronously, but more complex stuff should be delegated to background jobs.

### Controller

We have the controller `WebhooksController` that processes all kinds of webhooks using the retrievers mentioned above. The URL is `<HOST>/:integration`, so for Stripe we have `<HOST>/stripe`.

## General Information

- ⚠️ Create a `.env` file on the project root and copy the contents of `.env.sample` to it. ⚠️
- ⚠️ Place the provided `master.key` file on the `/config` folder. ⚠️
- In case you wish to test the Stripe webhooks manually, you'll have to change the `stripe.webhook_secret` used on the `config/credentials.yml.enc`.

## Development Environment Setup

- Build the containers
  - `docker-compose build`
- Start the containers
  - `docker-compose up`
- Create the database on the container
  - `docker-compose exec app bundle exec rails db:create`
- Run the database migrations on the app database
  - `docker-compose exec app bundle exec rails db:migrate`

## Test Environment Setup

- In case you haven't already done that, build the containers
  - `docker-compose build`
- Start the containers
  - `docker-compose up`
- In case you haven't already done that, create the database on the test container
  - `docker-compose exec app bundle exec rails db:create RAILS_ENV=test`
- Run the database migrations on the test database
  - `docker-compose exec app bundle exec rails db:migrate RAILS_ENV=test`
- Run the tests
  - `docker-compose exec app bundle exec rspec`
