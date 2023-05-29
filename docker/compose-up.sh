#! /bin/bash

if [[ ! $1 ]]; then
  echo "Usage: ./compose-up.sh <docker compose file> [<moqui directory>]"
  exit 1
fi

COMP_FILE="${1}"
MOQUI_HOME="${2:-..}"

#if [ ! -e runtime ]; then mkdir runtime; fi
#if [ ! -e runtime/base-component ]; then cp -R $MOQUI_HOME/runtime/base-component runtime/; fi
rm -Rf runtime
cp -Rf $MOQUI_HOME/runtime runtime
# set the project name to 'moqui', network will be called 'moqui_default'
docker compose -f $COMP_FILE -p moqui up -d
