# --- Stage 1: bundle into a standalone binary with PyInstaller ---
FROM python:3.13-alpine AS builder

RUN apk add --no-cache binutils musl-dev gcc
RUN pip install pyinstaller

WORKDIR /app
COPY hello.py .

RUN pyinstaller --onefile --clean hello.py

# --- Stage 2: minimal execution image ---
FROM alpine:3.20

COPY --from=builder /app/dist/hello /hello

ENTRYPOINT ["/hello"]
