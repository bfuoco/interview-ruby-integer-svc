FROM ruby:2.7.2
RUN mkdir /working
WORKDIR /working

COPY Gemfile /working/Gemfile
COPY Gemfile.lock /working/Gemfile.lock
RUN bundle install

COPY . /working
RUN chmod +x /working/bin/init

EXPOSE 9292
ENTRYPOINT /working/bin/init