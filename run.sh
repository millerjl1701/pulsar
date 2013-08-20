#!/bin/bash

## Usage:
## Start LWR server as daemon process:
##   run.sh --daemon   
## Stop LWR daemon process:
##   run.sh --stop-daemon

# Ensure working directory is lwr project. 
PROJECT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $PROJECT_DIRECTORY

if [ -d .venv ]; 
then
    . .venv/bin/activate
fi

# Set GALAXY_HOME to add Galaxy code base and dependencies to
# PYTHONPATH. This is required for many stock Galaxy tools.
if [ -n "$GALAXY_HOME" ]; 
then
    PYTHONPATH="$GALAXY_HOME/lib":$PYTHONPATH
    export PYTHONPATH
    echo "Added Galaxy libraries ($GALAXY_HOME/lib) to PYTHONPATH"
fi

# If TEST_GALAXY_LIBS is set, this script will attempt to verify
# Galaxy is properly placed on the LWR's PYTHONPATH before starting
# the server.
if [ -n "$TEST_GALAXY_LIBS" ];
then
    python -c "from galaxy import eggs"
    result=$?
    if [ "$result" == "0" ];
    then
        echo "Galaxy loaded properly."
    else
        echo "Failed to setup Galaxy environment properly, is GALAXY_HOME ($GALAXY_HOME) a valid Galaxy instance."
        exit $result
    fi
fi

# Setup default configuration files (if needed).
for file in 'server.ini'; do
    if [ ! -f "$file" -a -f "$file.sample" ]; then
        echo "Initializing $file from `basename $file.sample`"
        cp "$file.sample" "$file"
    fi
done

paster serve server.ini "$@"