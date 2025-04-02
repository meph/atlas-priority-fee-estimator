FROM rust:1.75-slim-bullseye as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire project
COPY . .

# Build the application
RUN cargo build --release

# Create a new stage with a minimal image
FROM debian:bullseye-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libssl1.1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary from builder
COPY --from=builder /app/target/release/atlas_priority_fee_estimator .

# Ensure the binary is executable
RUN chmod +x ./atlas_priority_fee_estimator

# Set the environment variables
ENV RUST_LOG=info

# Run the application
CMD ["./atlas_priority_fee_estimator"] 