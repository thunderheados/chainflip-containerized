FROM ubuntu:20.04

# Set the WORKDIR before the user change
WORKDIR /etc/chainflip

# Disable interactiveness in apt installations
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN --mount=type=cache,id=apt-cache,target=/var/cache/apt \
    apt-get update \
    && apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        sudo \
    && rm -rf /var/lib/apt/lists/*

# Add Chainflip package signing key
RUN curl -fsSL https://repo.chainflip.io/keys/gpg | gpg --dearmor \
    | tee /etc/apt/trusted.gpg.d/chainflip.gpg >/dev/null

# Add Chainflip repository to sources list
RUN echo "deb [signed-by=/etc/apt/trusted.gpg.d/chainflip.gpg] https://repo.chainflip.io/perseverance/ focal main" \
    | tee /etc/apt/sources.list.d/chainflip.list

# Install Chainflip packages
RUN --mount=type=cache,id=apt-cache,target=/var/cache/apt \
    apt-get update \
    && apt-get install -y \
        chainflip-cli \
        chainflip-node \
        chainflip-engine \
    && rm -rf /var/lib/apt/lists/*

RUN useradd flip && chown flip:flip -R /etc/chainflip

# Change to the non-root user
USER flip
