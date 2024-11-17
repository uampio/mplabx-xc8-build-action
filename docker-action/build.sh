#!/bin/bash

# Arguments passed to the script
PROJECT=${1:-firmware.X}
CONFIGURATION=${2:-default}

echo "Building project $1:$2"

set -xe

cd $PROJECT

cat $PROJECT/nbproject/configurations.xml

# Generate project makefiles
echo "Generating makefiles"
if ! /opt/mplabx/mplab_platform/bin/prjMakefilesGenerator.sh "$PROJECT@$CONFIGURATION"; then
    echo "Error: Failed to generate makefiles"
    exit 1
fi

# Build the project using make
echo "Building"
if ! make -C "$PROJECT" CONF="$CONFIGURATION" build; then
    echo "Error: Build failed for project $PROJECT with configuration $CONFIGURATION"
    exit 2
fi

echo "Build completed successfully"