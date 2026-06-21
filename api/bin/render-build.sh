#!/usr/bin/env bash
# Render runs this from the api/ rootDir on every deploy.
set -o errexit

bundle install
bundle exec rails db:migrate
