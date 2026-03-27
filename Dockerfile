FROM ruby:3.3.10

RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    tzdata \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

EXPOSE 3000
CMD ["sh", "-c", "rm -f tmp/pids/server.pid && rails server -b 0.0.0.0"]
