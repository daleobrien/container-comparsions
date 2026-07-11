FROM golang:1.23-alpine AS builder

WORKDIR /app
COPY main.go .

# Build a fully static, stripped binary
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o hello main.go

FROM scratch
COPY --from=builder /app/hello /hello
ENTRYPOINT ["/hello"]
