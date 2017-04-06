FROM avvo/ruby-rails-mysql
MAINTAINER Jake Sparling <jsparling@avvo.com>

ENV APP_HOME /srv/junit_visualizer/current

RUN apk update && \
    apk upgrade && \
    apk add build-base && \	
    rm -rf /var/cache/apk/*

RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

RUN mkdir -p $APP_HOME/vendor/bundle

ADD Gemfile* $APP_HOME/
ADD vendor/cache $APP_HOME/vendor/cache
RUN bundle install --path vendor/bundle --local --deployment --without development test

ADD . $APP_HOME

ENV RAILS_ENV production
ENV WORKERS 8

ENV MEMCACHED_HOSTS memcached:11211

ENV DB_HOST           mysql
ENV DB_PORT           3306
ENV DB_USER           junit_visualizer
ENV DB_PASS           thisisnotarealpassword

ARG SOURCE_COMMIT=0
RUN echo $SOURCE_COMMIT
ENV COMMIT_HASH $SOURCE_COMMIT

ENTRYPOINT ["bin/unicorn"]
CMD ["-c", "config/unicorn.rb"]
