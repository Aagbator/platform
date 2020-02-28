#!/bin/bash
echo "Refreshing your local dev database"

docker-compose down
docker volume rm platform_db-platform
docker-compose up -d
sleep 5 # wait for containers to be up and accepting connections

docker-compose exec platformweb bundle exec rake db:create db:migrate db:dummies

# Note: this is fast than a db:migrate but if your'e actively working on db migrations
# you're likely doing a dbrefresh to get back to a pristine state after you've been
# iterating and db/schema.rb may not be correct yet.
#docker-compose exec platformweb bundle exec rake db:create db:schema:load db:dummies



