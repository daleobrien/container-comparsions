FROM oven/bun:1-alpine AS builder

WORKDIR /app
COPY hello.js .

# Compile to a standalone binary
RUN bun build --compile ./hello.js --outfile hello

FROM alpine:3.20
RUN apk add --no-cache libstdc++ libgcc
COPY --from=builder /app/hello /hello
ENTRYPOINT ["/hello"]
