# --- Stage 1: compile to a native binary with GraalVM ---
FROM ghcr.io/graalvm/native-image-community:25 AS builder

WORKDIR /app
COPY HelloWorld.java .

RUN javac HelloWorld.java
RUN native-image -o hello HelloWorld

# --- Stage 2: minimal distroless runtime ---
FROM gcr.io/distroless/cc-debian12

COPY --from=builder /app/hello /hello

ENTRYPOINT ["/hello"]
