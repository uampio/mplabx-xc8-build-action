#!/bin/bash

echo "MPLABX_VERSION: $MPLABX_VERSION"
echo "XC8_VERSION: $XC8_VERSION"
echo "DFP_PACKS: $DFP_PACKS"
echo "PROJECT: $PROJECT"
echo "CONFIGURATION: $CONFIGURATION"

# Arguments passed to the script
PROJECT=${4:-firmware.X}
CONFIGURATION=${5:-default}

echo "Building $PROJECT with configuration $CONFIGURATION"

set -xe

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
