# rust-docker

Minimal Dockerized "hello world" in Rust, C++, Node.js, and Java — Rust and C++ build `FROM scratch` with zero runtime dependencies, while Node.js uses a SEA (Single Executable Application) on Alpine and Java uses GraalVM Native Image on distroless.

| Example | Approach | Binary |
|---------|----------|--------|
| `rust/` | musl-static release build + `strip` | `~400 KB` |
| `cpp/` | `_start` entry, raw syscalls, `-nostdlib` + `strip` | *tiny* |
| `node/` | Node.js SEA (Single Executable Application) + Alpine | `~80 MB` |
| `java/` | GraalVM Native Image + distroless cc | `~30 MB` |

## Quick start

```sh
chmod +x run.sh && ./run.sh
```
