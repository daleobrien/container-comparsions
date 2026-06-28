# rust-docker

Minimal Dockerized "hello world" in Rust, C++, Node.js, Java, and Python — Rust and C++ build `FROM scratch` with zero runtime dependencies, while the interpreted languages use AOT/bundling tools on minimal base images.

| Example | Approach | Binary |
|---------|----------|--------|
| `rust/` | musl-static release build + `strip` | `~400 KB` |
| `cpp/` | `_start` entry, raw syscalls, `-nostdlib` + `strip` | *tiny* |
| `node/` | Node.js SEA (Single Executable Application) + Alpine | `~80 MB` |
| `java/` | GraalVM Native Image + distroless cc | `~30 MB` |
| `python/` | PyInstaller bundler + Alpine | `~25 MB` |

## Quick start

```sh
chmod +x run.sh && ./run.sh
```
