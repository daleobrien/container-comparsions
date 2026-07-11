FROM alpine:edge AS builder

RUN apk add --no-cache zig binutils

WORKDIR /app
COPY main.zig .

# Build a minimal static binary using musl
# Note: -fstrip removed (default in release modes in recent Zig); -target uses full triple
RUN zig build-exe -O ReleaseSmall -target native-native-musl main.zig

FROM scratch
COPY --from=builder /app/main /hello
ENTRYPOINT ["/hello"]
