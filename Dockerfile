
FROM ubuntu:24.04

# Set environment variables from build arguments
ARG MPLABX_VERSION
ARG XC8_VERSION
ARG DFP_PACKS
ARG PROJECT
ARG CONFIGURATION

RUN echo "MPLABX Version $MPLABX_VERSION"
RUN echo "XC8 Version $XC8_VERSION"
RUN echo "DFP Packs: $DFP_PACKS"
RUN echo "Project: $PROJECT"
RUN echo "Configuration: $CONFIGURATION"

# Set non-interactive mode for tzdata
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies
RUN apt-get update -qq && apt-get install -y -qq \
    wget \
    tar \
    sudo \
    libusb-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install make and gcc
RUN apt-get update && \
    apt-get install -y make gcc && \
    rm -rf /var/lib/apt/lists/*

# Download and install MPLAB X IDE
RUN wget -q --referer="https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide" \
    -O /tmp/MPLABX-v${MPLABX_VERSION}-linux-installer.tar \
    https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/MPLABX-v${MPLABX_VERSION}-linux-installer.tar && \
    cd /tmp && \
    tar -xf MPLABX-v${MPLABX_VERSION}-linux-installer.tar && \
    mv "MPLABX-v${MPLABX_VERSION}-linux-installer.sh" mplabx && \
    chmod +x mplabx && \
    sudo ./mplabx -- --unattendedmodeui none --mode unattended --ipe 0 --collectInfo 0 --installdir /opt/mplabx --16bitmcu 0 --32bitmcu 1 --othermcu 0 && \
    rm mplabx

# Download and install XC8 compiler
RUN wget -nv -O /tmp/xc8 "https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/xc8-v${XC8_VERSION}-full-install-linux-x64-installer.run" && \
    chmod +x /tmp/xc8 && \
    sudo /tmp/xc8 --mode unattended --unattendedmodeui none --netservername localhost --LicenseType FreeMode --prefix "/opt/microchip/xc8/v${XC8_VERSION}" && \
    rm /tmp/xc8

# Install DFPs
RUN if [ -n "$DFP_PACKS" ]; then \
    echo "Installing DFPs: $DFP_PACKS"; \
    sudo chmod +x /opt/mplabx/mplab_platform/bin/packmanagercli.sh; \
    for pack in $(echo "$DFP_PACKS" | tr "," "\n"); do \
        pack_name=$(echo "$pack" | cut -d '=' -f 1); \
        pack_version=$(echo "$pack" | cut -d '=' -f 2); \
        echo "Installing package: $pack_name (Version: $pack_version)"; \
        sudo /opt/mplabx/mplab_platform/bin/packmanagercli.sh --install-pack "$pack_name" --version "$pack_version" > /dev/null 2>&1; \
    done; \
fi

# Copy build script
COPY build.sh /build.sh

# Make the build script executable
RUN chmod +x /build.sh

# Set the entry point to the build script
ENTRYPOINT ["/build.sh"]
