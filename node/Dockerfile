# --- Stage 1: produce a standalone Node.js binary via SEA ---
FROM node:22-alpine AS builder

RUN apk add --no-cache python3 make g++ upx

WORKDIR /app
COPY hello.js sea-config.json ./

# Create a SEA (Single Executable Application) blob
RUN node --experimental-sea-config sea-config.json

# Copy node binary, strip, and UPX-compress it
RUN cp $(command -v node) hello-sea
RUN strip hello-sea
RUN upx --best hello-sea

# Inject the SEA blob into the compressed binary
RUN npx --yes postject hello-sea NODE_SEA_BLOB sea-prep.blob \
    --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2

# --- Stage 2: minimal execution image ---
FROM scratch

# Copy the dynamic linker (musl libc is embedded in it)
COPY --from=builder /lib/ld-musl-aarch64.so.1 /lib/ld-musl-aarch64.so.1

# The node SEA binary links against libstdc++ and libgcc_s
COPY --from=builder /usr/lib/libstdc++.so.6 /usr/lib/libstdc++.so.6
COPY --from=builder /usr/lib/libgcc_s.so.1 /usr/lib/libgcc_s.so.1

COPY --from=builder /app/hello-sea /hello

ENTRYPOINT ["/hello"]
