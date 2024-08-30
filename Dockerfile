ARG RUBY_VERSION=3.1
FROM ruby:${RUBY_VERSION} AS base

RUN apt-get update && apt-get -y upgrade && apt-get -y install git jq

FROM base AS builder

COPY Gemfile marc_to_argot.gemspec VERSION .

RUN gem install bundler

RUN bundle config set path /gems && bundle config set with production test development && bundle install

FROM base

COPY --from=builder /gems /gems

RUN bundle config set path /gems

RUN echo "cd /app" >> ~/.bashrc

CMD ["/bin/bash"]
