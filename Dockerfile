# Purpose: Multi-stage production Dockerfile for Rails API.
# Stage 1 (builder): installs gems. BUNDLE_WITHOUT controls which groups.
#   - Production default: "development test" (small image)
#   - Development override via docker-compose: "" (all gems, needed for rspec etc.)
# Stage 2 (production): minimal runtime image with non-root user.

# --- Stage 1: Builder ---
FROM ruby:3.3.10-slim AS builder

# BUNDLE_WITHOUT allows docker-compose dev to override and include dev/test gems.
# Default is "development test" for production builds.
ARG BUNDLE_WITHOUT="development test"
ENV BUNDLE_WITHOUT=${BUNDLE_WITHOUT}

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    libyaml-dev \
    git \
    pkg-config && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
# Install gems to GEM_HOME (/usr/local/bundle), which the production stage copies over.
# BUNDLE_WITHOUT is passed as a build ARG so dev builds include all gems.
# No deployment mode — deployment mode redirects gems to vendor/bundle, which the
# .:/app volume mount would hide at runtime.
RUN bundle install --jobs 4 --retry 3 && \
    rm -rf /usr/local/bundle/cache

COPY . .

# Precompile bootsnap cache for faster boot
RUN bundle exec bootsnap precompile --gemfile app/ lib/

# --- Stage 2: Production ---
FROM ruby:3.3.10-slim AS production

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    libpq5 \
    libyaml-0-2 \
    curl \
    libjemalloc2 && \
    rm -rf /var/lib/apt/lists/*

# Detect jemalloc path dynamically to support both x86_64 and ARM (aarch64) hosts.
# Falls back to no preload if the file isn't found rather than crashing.
RUN JEMALLOC_PATH=$(find /usr/lib -name "libjemalloc.so.2" 2>/dev/null | head -1) && \
    if [ -n "$JEMALLOC_PATH" ]; then echo "LD_PRELOAD=$JEMALLOC_PATH" >> /etc/environment; fi

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    BUNDLE_WITHOUT="development test"

WORKDIR /app

# Create non-root user for security
RUN groupadd --system rails && \
    useradd --system --gid rails --create-home rails && \
    mkdir -p tmp/pids tmp/cache log storage && \
    chown -R rails:rails tmp log storage

# Copy built artifacts from builder stage
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle /usr/local/bundle

RUN chown -R rails:rails /app

USER rails

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:3000/up || exit 1

ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
