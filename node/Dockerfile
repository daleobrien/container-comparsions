# --- Stage 1: produce a standalone Node.js binary via SEA ---
FROM node:22-alpine AS builder

RUN apk add --no-cache python3 make g++

WORKDIR /app
COPY hello.js sea-config.json ./

# Create a SEA (Single Executable Application) blob
RUN node --experimental-sea-config sea-config.json

# Inject the blob into the node binary to produce a self-contained executable
RUN cp $(command -v node) hello-sea
RUN npx --yes postject hello-sea NODE_SEA_BLOB sea-prep.blob \
    --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2

# Strip debug symbols to reduce size
RUN strip hello-sea

# --- Stage 2: minimal execution image ---
# Alpine provides musl libc needed by the Node.js SEA binary
FROM alpine:3.20

COPY --from=builder /app/hello-sea /hello

ENTRYPOINT ["/hello"]
