FROM rust:1.80-alpine AS builder

# Install musl-dev to handle C-dependencies during building
RUN apk add --no-cache musl-dev

WORKDIR /app
COPY . .

# Build with optimizations and strip debug symbols to reduce binary size
RUN cargo build --release
RUN strip target/release/hello

# --- Stage 2: Create the minimal execution image ---
FROM scratch

# Copy the compiled binary from the builder stage
COPY --from=builder /app/target/release/hello /hello

# (Optional) Copy SSL certificates if your app makes HTTPS requests
# COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT ["/hello"]
