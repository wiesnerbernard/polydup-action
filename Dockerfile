FROM debian:bookworm-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    jq \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download pre-built polydup binary from GitHub releases
RUN curl -L https://github.com/wiesnerbernard/polydup/releases/download/v0.5.0/polydup-linux-x86_64 -o /usr/local/bin/polydup \
    && chmod +x /usr/local/bin/polydup

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
