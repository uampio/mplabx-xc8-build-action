#!/bin/bash

echo "MPLABX_VERSION: $MPLABX_VERSION"
echo "XC8_VERSION: $XC8_VERSION"
echo "DFP_PACKS: $DFP_PACKS"
echo "PROJECT: $PROJECT"
echo "CONFIGURATION: $CONFIGURATION"

# Arguments passed to the script
# PROJECT=${4:-firmware.X}
# CONFIGURATION=${5:-default}

echo "Building $PROJECT with configuration $CONFIGURATION"

set -xe

# Download and install MPLABX
wget -q --referer="https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide" \
    -O /tmp/MPLABX-v${MPLABX_VERSION}-linux-installer.tar \
    https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/MPLABX-v${MPLABX_VERSION}-linux-installer.tar

cd /tmp

tar -xf MPLABX-v${MPLABX_VERSION}-linux-installer.tar
mv "MPLABX-v${MPLABX_VERSION}-linux-installer.sh" mplabx
chmod +x mplabx

sudo ./mplabx -- --unattendedmodeui none --mode unattended --ipe 0 --collectInfo 0 --installdir /opt/mplabx --16bitmcu 0 --32bitmcu 1 --othermcu 0

rm -rf mplabx

# Download and install XC8 compiler
wget -nv -O /tmp/xc8 "https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/xc8-v${XC8_VERSION}-full-install-linux-x64-installer.run"
chmod +x /tmp/xc8

sudo /tmp/xc8 --mode unattended --unattendedmodeui none --netservername localhost --LicenseType FreeMode --prefix "/opt/microchip/xc8/v${XC8_VERSION}"

rm -rf /tmp/xc8

echo "MPLABX and XC8 installation complete."

sudo chmod +x /opt/mplabx/mplab_platform/bin/packmanagercli.sh

echo "--Free memory available--"
free -h
echo "--Free memory available--"

rm -rf ~/.mchp_packs/cache/

output=$(sudo /opt/mplabx/mplab_platform/bin/packmanagercli.sh --list-packs --verbose 2>&1)
echo "$output"

# Install DFPs
if [ -n "$DFP_PACKS" ]; then
    echo "Installing DFPs: $DFP_PACKS"
    
    IFS=',' read -ra PACK_ARRAY <<< "$DFP_PACKS"
    for pack in "${PACK_ARRAY[@]}"; do
        pack_name=$(echo "$pack" | cut -d '=' -f 1)
        pack_version=$(echo "$pack" | cut -d '=' -f 2)
        echo "Installing package: $pack_name (Version: $pack_version)"
        output=$(sudo /opt/mplabx/mplab_platform/bin/packmanagercli.sh --install-pack "$pack_name" --version "$pack_version" --vendor Microchip --verbose 2>&1)
        echo "$output"
    done
fi

echo "DFP installation check complete."

cd ~

pwd

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
