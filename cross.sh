#!/bin/bash -x

PROJECT="sniff"
HOSTS="192.168.1.180"
FILES="lib src test mix.* make.* *.bat"

for HOST in $HOSTS; do
  ssh $HOST mkdir -p .cross/$PROJECT
  rsync -r --delete $FILES $HOST:.cross/$PROJECT/
  ssh $HOST "cd .cross/$PROJECT/ && mix deps.get && mix test"
done