FROM rust:1.75-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install polydup-cli from crates.io
RUN cargo install polydup-cli --version 0.5.0

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
