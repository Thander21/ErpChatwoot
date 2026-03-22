#!/bin/sh

set -x

# Remove a potentially pre-existing server.pid for Rails.
rm -rf /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/*

echo "Waiting for postgres to become ready...."

# Let DATABASE_URL env take precedence over individual connection params.
# This is done to avoid printing the DATABASE_URL in the logs
$(docker/entrypoints/helpers/pg_database_url.rb)
# Check if variables are empty to prevent pg_isready argument errors
PG_PORT_ARG=${POSTGRES_PORT:+"-p $POSTGRES_PORT"}
PG_HOST_ARG=${POSTGRES_HOST:+"-h $POSTGRES_HOST"}
PG_USER_ARG=${POSTGRES_USERNAME:+"-U $POSTGRES_USERNAME"}

PG_READY="pg_isready $PG_HOST_ARG $PG_PORT_ARG $PG_USER_ARG"

until $PG_READY
do
  sleep 2;
done

echo "Database ready to accept connections."

#install missing gems for local dev as we are using base image compiled for production
bundle install

BUNDLE="bundle check"

until $BUNDLE
do
  sleep 2;
done

# Inject custom enterprise routes if inclusion is missing
if ! grep -q "enterprise/config/routes.rb" config/routes.rb; then
  echo "Injecting enterprise routes inclusion..."
  # Insert before the last 'end'
  sed -i '$i \  instance_eval(File.read(Rails.root.join("enterprise/config/routes.rb"))) if Rails.root.join("enterprise/config/routes.rb").exist?' config/routes.rb
fi

# Execute the main process of the container
exec "$@"
