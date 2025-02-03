
FROM ubuntu:latest

# Set environment variables from build arguments
#ENV MPLABX_VERSION=6.20
#ENV XC8_VERSION=3.00
#ENV DFP_PACKS=ATtiny_DFP=3.2.268

#RUN echo "MPLABX Version $MPLABX_VERSION"
#RUN echo "XC8 Version $XC8_VERSION"
#RUN echo "DFP Packs: $DFP_PACKS"

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

# Install java
RUN apt update && apt install openjdk-11-jd

# Copy build script
COPY build.sh /build.sh

# Make the build script executable
RUN chmod +x /build.sh

# Set the entry point to the build script
ENTRYPOINT ["/build.sh"]
