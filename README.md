# Container Comparsions

Minimal Dockerized "hello world" in Rust, C++, Haskell, Node.js, Java, and Python — compiled languages build `FROM scratch` with zero runtime dependencies, while the interpreted languages use AOT/bundling tools on minimal base images.

## Quick start

```sh
chmod +x run.sh

./run.sh
=== Building with Docker ===
=== Building with Apple Container ===

=== Benchmark (10 runs each) ===
IMAGE              RUNTIME          SIZE     PROGRESS          AVG
────────────────── ────────── ────────── ──────────── ────────────
hello-rust         docker         395 kB     [ done ]   163.10 ms
hello-cpp          docker          832 B     [ done ]   152.56 ms
hello-node         docker         118 MB     [ done ]   161.60 ms
hello-java         docker        47.3 MB     [ done ]   156.00 ms
hello-python       docker        27.2 MB     [ done ]   183.16 ms
hello-haskell      docker        1.06 MB     [ done ]   153.17 ms
hello-rust         apple          212 KB     [ done ]   726.48 ms
hello-cpp          apple            2 KB     [ done ]   703.23 ms
hello-node         apple         47.4 MB     [ done ]   705.33 ms
hello-java         apple         13.5 MB     [ done ]   691.82 ms
hello-python       apple         12.1 MB     [ done ]   771.55 ms
hello-haskell      apple          375 KB     [ done ]   761.17 ms
```

## Options

`run.sh` supports the following environment variables:

| Variable | Effect |
|----------|--------|
| `SKIP_APPLE=1` | Skip Apple Container builds entirely (Docker only) |
| `VERBOSE=1` | Show full build output instead of suppressing it |
| `N_RUNS=25` | Number of benchmark runs per image (default: `10`) |

### Examples

```sh
# Docker + Apple Container (default)
./run.sh

# Docker only
SKIP_APPLE=1 ./run.sh

# Docker + Apple Container, with verbose build output
VERBOSE=1 ./run.sh

# Docker only, verbose
SKIP_APPLE=1 VERBOSE=1 ./run.sh
```
