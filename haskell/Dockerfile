# --- Stage 1: compile to a static native binary with GHC ---
FROM alpine:3.21 AS builder

RUN apk add --no-cache ghc binutils gcc musl-dev

WORKDIR /app
COPY hello.hs .

RUN ghc -O2 -static -optl-static -optl-pthread -o hello hello.hs
RUN strip hello

# --- Stage 2: minimal execution image ---
# GHC on musl produces fully static binaries — no libc needed
FROM scratch

COPY --from=builder /app/hello /hello

ENTRYPOINT ["/hello"]
