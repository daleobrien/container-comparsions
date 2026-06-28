# rust-docker

Minimal Dockerized "hello world" in Rust and C++ — both built `FROM scratch` with zero runtime dependencies.

| Example | Approach | Binary |
|---------|----------|--------|
| `rust/` | musl-static release build + `strip` | `~400 KB` |
| `cpp/` | `_start` entry, raw syscalls, `-nostdlib` + `strip` | *tiny* |

## Quick start

```sh
chmod +x run.sh && ./run.sh
```
