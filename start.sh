#!/bin/bash

set -x

# Don't run if HALT is set
if [ "$HALT" == "1" ]; then
  echo "start.sh: ENV HALT=1; don't do anything"
  exit
fi

# Dump the env for debugging
env

# If we're missing certs, register our device
if [[ -z "$AWS_CERT" || -z "$AWS_PRIVATE_KEY" || -z "$AWS_ROOT_CA" ]]; then
  echo "start.sh: Creating AWS certificates"

  curl -X POST -H "Cache-Control: no-cache" \
    -d '{ "uuid": "'$RESIN_DEVICE_UUID'", "attributes": { "someKey": "someVal" } }' \
    $LAMBDA

fi

# If we're still missing certs, abort
if [[ -z ${AWS_CERT+x} || -z ${AWS_PRIVATE_KEY+x} || -z ${AWS_ROOT_CA+x} ]]; then
  echo "fatal: start.sh: AWS_CERT, AWS_PRIVATE_KEY and/or AWS_ROOT_CA not set! exiting!"

  exit 1
fi

# Otherwise, run the app
echo "start.sh: AWS certificates exist - running app"
echo "Rendering image"

if [ -z "$ROTATE" ]; then
    ROTATE=0
fi

mkdir -p rotated/images
for file in $(ls images/*.png | xargs echo); do
  convert $file -rotate $ROTATE rotated/$file
done

which node
node --version

node app.js

