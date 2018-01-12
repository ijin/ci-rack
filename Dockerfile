FROM ruby:2.4.2-alpine

ARG rails_env="staging"

ENV APP_ROOT /app
ENV RAILS_ENV ${rails_env}

#RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
#    apt-get update && \
#    apt-get install -y --no-install-recommends build-essential nodejs mysql-client imagemagick python3-dev python3-pip && \
#    rm -rf /var/lib/apt/lists/*
RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base \
  && pip install virtualenv \
  && rm -rf /var/cache/apk/*

RUN pip install awscli

WORKDIR $APP_ROOT

COPY Gemfile Gemfile.lock ./

RUN bundle install --path vendor/bundle

COPY . .

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_SESSION_TOKEN

EXPOSE 9292

CMD ["bundle", "exec", "ruby", "hello.rb"]
