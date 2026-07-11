FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS builder

# Native AOT toolchain requires clang and linker
RUN apk add --no-cache clang lld musl-dev binutils

WORKDIR /app
COPY *.cs *.csproj .

# Native AOT compilation produces a fully static binary on Alpine/musl
RUN dotnet publish -c Release -p:PublishAot=true -p:StripSymbols=true -o out

FROM scratch
COPY --from=builder /app/out/hello /hello
ENTRYPOINT ["/hello"]
