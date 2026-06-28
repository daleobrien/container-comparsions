FROM alpine:3.20 AS builder

RUN apk add --no-cache g++ binutils

WORKDIR /app
COPY main.cpp .

# Build a fully static, stripped binary with no standard library
RUN g++ -static -nostdlib    \
    -Os                       \
    -fno-exceptions           \
    -fno-rtti                 \
    -ffunction-sections       \
    -fdata-sections           \
    -Wl,--gc-sections         \
    -o hello main.cpp

RUN strip hello

FROM scratch
COPY --from=builder /app/hello /hello
ENTRYPOINT ["/hello"]
