# syntax=docker/dockerfile:1
# Based on chatwoot-base/docker/Dockerfile

# pre-build stage
FROM node:24-alpine AS node
FROM ruby:3.4.4-alpine3.21 AS pre-builder

ARG NODE_VERSION="24.13.0"
ARG PNPM_VERSION="10.2.0"
ENV NODE_VERSION=${NODE_VERSION}
ENV PNPM_VERSION=${PNPM_VERSION}

ARG BUNDLE_WITHOUT="development:test"
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}
ENV BUNDLER_VERSION=2.5.16

ARG RAILS_SERVE_STATIC_FILES=true
ENV RAILS_SERVE_STATIC_FILES ${RAILS_SERVE_STATIC_FILES}

ARG RAILS_ENV=production
ENV RAILS_ENV ${RAILS_ENV}

ARG NODE_OPTIONS="--max-old-space-size=4096 --openssl-legacy-provider"
ENV NODE_OPTIONS ${NODE_OPTIONS}

ENV BUNDLE_PATH="/gems"

RUN apk update && apk add --no-cache \
    openssl \
    tar \
    build-base \
    tzdata \
    postgresql-dev \
    postgresql-client \
    git \
    curl \
    xz \
    && mkdir -p /var/app \
    && gem install bundler -v "$BUNDLER_VERSION"

COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

RUN npm install -g pnpm@${PNPM_VERSION}

RUN echo 'export PNPM_HOME="/root/.local/share/pnpm"' >> /root/.shrc \
    && echo 'export PATH="$PNPM_HOME:$PATH"' >> /root/.shrc \
    && export PNPM_HOME="/root/.local/share/pnpm" \
    && export PATH="$PNPM_HOME:$PATH" \
    && pnpm --version

# Persist the environment variables in Docker
ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

WORKDIR /app

# COPY Gemfiles (Base + Patch)
COPY chatwoot-base/Gemfile ./Gemfile
# Overwrite with patched lockfile if available, otherwise use base
COPY chatwoot-base/Gemfile.lock ./Gemfile.lock




# Patch Gemfile to include dependencies required by MenuPdvD+
# Patch Gemfile to include dependencies required by MenuPdvD+
RUN sed -i "1i gem 'httparty'\ngem 'multi_xml'" ./Gemfile


# Native compile deps
RUN apk update && apk add --no-cache build-base musl ruby-full ruby-dev gcc make musl-dev openssl openssl-dev g++ linux-headers xz vips rust cargo clang clang-libclang yaml-dev
RUN bundle config set --local force_ruby_platform true

# Install Gems
RUN if [ "$RAILS_ENV" = "production" ]; then \
    bundle config set without 'development test'; bundle install -j 4 -r 3; \
    else bundle install -j 4 -r 3; \
    fi

# COPY Node Deeps
COPY chatwoot-base/package.json chatwoot-base/pnpm-lock.yaml ./
RUN pnpm i

# COPY Source Code (Base)
COPY chatwoot-base /app
RUN rm -f /app/.env


# APPLY PATCHES (MenuPdvD+)
# 1. Enterprise folder
COPY MenuPdvD+/enterprise /app/enterprise
# 2. Core patches
COPY MenuPdvD+/core-patches/dashboard.routes.js /app/app/javascript/dashboard/routes/dashboard/
COPY MenuPdvD+/core-patches/Sidebar.vue /app/app/javascript/dashboard/components-next/sidebar/
COPY MenuPdvD+/core-patches/settings.json /app/app/javascript/dashboard/i18n/locale/en/
# 3. Migrations
COPY MenuPdvD+/db/migrate /app/db/migrate
# 3.1 API Patches
COPY MenuPdvD+/enterprise/app/javascript/dashboard/api/kanbanCards.js /app/app/javascript/dashboard/api/
COPY MenuPdvD+/enterprise/app/helpers/enterprise_helper.rb /app/app/helpers/
# 4. Configs
# COPY MenuPdvD+/vite.config.ts /app/
RUN sed -i "s|      assets: path.resolve('./app/javascript/dashboard/assets'),|      assets: path.resolve('./app/javascript/dashboard/assets'),\n      enterprise: path.resolve('./enterprise'),|" ./vite.config.ts

# Logging
RUN mkdir -p /app/log

# Assets Precompile
RUN if [ "$RAILS_ENV" = "production" ]; then \
    SECRET_KEY_BASE=precompile_placeholder RAILS_LOG_TO_STDOUT=enabled bundle exec rake assets:precompile \
    && rm -rf spec node_modules tmp/cache; \
    fi

# Git SHA (Generic)
RUN echo "custom-build" > /app/.git_sha

# Cleanup
RUN rm -rf /gems/ruby/3.4.0/cache/*.gem \
    && find /gems/ruby/3.4.0/gems/ \( -name "*.c" -o -name "*.o" \) -delete \
    && rm -rf .git \
    && rm .gitignore

# final build stage
FROM ruby:3.4.4-alpine3.21

ARG NODE_VERSION="24.13.0"
ARG PNPM_VERSION="10.2.0"
ENV NODE_VERSION=${NODE_VERSION}
ENV PNPM_VERSION=${PNPM_VERSION}

ARG BUNDLE_WITHOUT="development:test"
ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}
ENV BUNDLER_VERSION=2.5.16

ARG EXECJS_RUNTIME="Disabled"
ENV EXECJS_RUNTIME ${EXECJS_RUNTIME}

ARG RAILS_SERVE_STATIC_FILES=true
ENV RAILS_SERVE_STATIC_FILES ${RAILS_SERVE_STATIC_FILES}

ARG BUNDLE_FORCE_RUBY_PLATFORM=1
ENV BUNDLE_FORCE_RUBY_PLATFORM ${BUNDLE_FORCE_RUBY_PLATFORM}

ARG RAILS_ENV=production
ENV RAILS_ENV ${RAILS_ENV}
ENV BUNDLE_PATH="/gems"

RUN apk update && apk add --no-cache \
    build-base \
    openssl \
    tzdata \
    postgresql-client \
    imagemagick \
    git \
    vips \
    && gem install bundler -v "$BUNDLER_VERSION"

COPY --from=node /usr/local/bin/node /usr/local/bin/
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN if [ "$RAILS_ENV" != "production" ]; then \
    apk add --no-cache curl \
    && ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && npm install -g pnpm@${PNPM_VERSION} \
    && pnpm --version; \
    fi

COPY --from=pre-builder /gems/ /gems/
COPY --from=pre-builder /app /app
COPY --from=pre-builder /app/.git_sha /app/.git_sha

WORKDIR /app
EXPOSE 3000

CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
