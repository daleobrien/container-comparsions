# --- Stage 1: compile to a native binary with GraalVM ---
FROM ghcr.io/graalvm/native-image-community:25 AS builder

WORKDIR /app
COPY HelloWorld.java .

RUN javac HelloWorld.java
RUN native-image -o hello HelloWorld

# --- Stage 2: minimal distroless runtime ---
FROM gcr.io/distroless/cc-debian12

COPY --from=builder /app/hello /hello

# cc-debian12 has glibc + libgcc + libstdc++, but is missing zlib.
# Copy it from the builder to /lib/ (always in the default search path).
COPY --from=builder /lib64/libz* /lib/
COPY --from=builder /usr/lib64/libz* /lib/

ENTRYPOINT ["/hello"]
