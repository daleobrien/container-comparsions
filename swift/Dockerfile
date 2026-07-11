FROM swift:6.0 AS builder

WORKDIR /app
COPY main.swift .

# Compile with optimizations, linking dynamically against Swift runtime
RUN swiftc -O -o hello main.swift
RUN strip hello

# Runtime-only image — much smaller, already has Swift standard libraries
FROM swift:6.0-slim

COPY --from=builder /app/hello /hello

ENTRYPOINT ["/hello"]
