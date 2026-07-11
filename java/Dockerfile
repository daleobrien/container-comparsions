# --- Stage 1: compile to a native binary with GraalVM ---
FROM ghcr.io/graalvm/native-image-community:25 AS builder

WORKDIR /app
COPY HelloWorld.java .

RUN javac HelloWorld.java
RUN native-image -o hello HelloWorld
RUN strip hello

# --- Stage 2: scratch + only the 3 shared libraries the binary needs ---
FROM scratch

# The native-image binary (stripped)
COPY --from=builder /app/hello /hello

# libc + zlib (all we need for a simple CLI app)
COPY --from=builder /lib/ld-linux-aarch64.so.1 /lib/
COPY --from=builder /lib64/libc.so.6 /lib64/
COPY --from=builder /lib64/libz.so.1.3.1.zlib-ng /lib64/libz.so.1.3.1.zlib-ng
COPY --from=builder /lib64/libz.so.1 /lib64/libz.so.1

ENTRYPOINT ["/hello"]
