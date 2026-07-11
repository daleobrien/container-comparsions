FROM alpine:3.20 AS builder

RUN apk add --no-cache gcc binutils

WORKDIR /app
COPY main.c .

# Build a fully static, stripped binary with no standard library
RUN gcc -static -nostdlib    \
    -Os                       \
    -ffunction-sections       \
    -fdata-sections           \
    -Wl,--gc-sections         \
    -o hello main.c

RUN strip hello

FROM scratch
COPY --from=builder /app/hello /hello
ENTRYPOINT ["/hello"]
