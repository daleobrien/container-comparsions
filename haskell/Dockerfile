# --- Stage 1: compile to a static native binary with GHC ---
FROM haskell:9.10-alpine AS builder

WORKDIR /app
COPY hello.hs .

RUN ghc -O2 -o hello hello.hs
RUN strip hello

# --- Stage 2: minimal execution image ---
# GHC on musl produces fully static binaries — no libc needed
FROM scratch

COPY --from=builder /app/hello /hello

ENTRYPOINT ["/hello"]
