FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy pre-built binary
COPY bin/polydup /usr/local/bin/polydup
RUN chmod +x /usr/local/bin/polydup

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
