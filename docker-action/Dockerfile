FROM ubuntu:24.04

ARG MPLABX_VERSION=6.20
ARG XC8_VERSION=2.50

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

RUN echo "Downloading MPLAB X IDE Link: https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/MPLABX-v${MPLABX_VERSION}-linux-installer.tar" 
    
RUN wget -q --referer="https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide" \
    -O /tmp/MPLABX-v${MPLABX_VERSION}-linux-installer.tar \
    https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/MPLABX-v${MPLABX_VERSION}-linux-installer.tar

RUN echo "Download complete. Listing /tmp directory:" && \
    ls -l /tmp && \

RUN echo "Extracting tar file..." && \
    cd /tmp && \
    tar -xf MPLABX-v${MPLABX_VERSION}-linux-installer.tar && \
    echo "Extraction complete. Listing /tmp directory:" && \
    ls -l /tmp && \
    echo "Moving installer script..." && \
    mv "MPLABX-v${MPLABX_VERSION}-linux-installer.sh" mplabx && \
    echo "Setting execute permissions..." && \
    chmod +x mplabx && \
    echo "Running installer..." && \
    ./mplabx -- --unattendedmodeui none --mode unattended --ipe 0 --collectInfo 0 --installdir /opt/mplabx --16bitmcu 0 --32bitmcu 1 --othermcu 0 && \
    echo "Installation complete. Cleaning up..." && \
    rm mplabx && \
    echo "MPLAB X IDE installation finished."

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
        sudo /opt/mplabx/mplab_platform/bin/packmanagercli.sh --install-pack "$pack_name" --version "$pack_version" > /dev/null 2>&1; \
    done; \
fi

COPY build.sh /build.sh

RUN ["chmod", "+x", "/build.sh"]

ENTRYPOINT [ "/build.sh" ]