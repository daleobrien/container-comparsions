# Container Comparsions

Minimal Dockerized "hello world" in Rust, C++, Haskell, Node.js, Java, and Python — compiled languages build `FROM scratch` with zero runtime dependencies, while the interpreted languages use AOT/bundling tools on minimal base images.

## Quick start

```sh
chmod +x run.sh && ./run.sh
```

The script displays a live-updating comparison table that fills in as builds and benchmarks complete:

```
IMAGE           DOCKER SIZE     DOCKER AVG     APPLE SIZE      APPLE AVG    COLIMA SIZE     COLIMA AVG
──────────── ────────────── ────────────── ────────────── ────────────── ────────────── ──────────────
✓ bun           100,975,660      165.00 ms     40,949,056      827.52 ms    101,691,392      563.01 ms
✓ c                     944      147.87 ms          1,578      714.62 ms          8,192      531.53 ms
✓ cpp                   944      161.11 ms          1,578      713.12 ms          8,192      520.10 ms
✓ dotnet          1,451,496      157.55 ms        708,499      738.14 ms      1,458,176      520.64 ms
✓ go              1,441,944      150.45 ms        603,357      720.04 ms      1,449,984      512.35 ms
✓ haskell         1,326,728      152.39 ms        591,856      697.92 ms      1,331,200      528.51 ms
✓ java           16,450,152      149.28 ms      6,003,293      729.82 ms     16,498,688      551.65 ms
✓ node          120,835,540      172.41 ms     48,427,350      771.52 ms    121,552,896      541.44 ms
✓ php           105,603,450      160.40 ms     41,276,045      749.77 ms    109,223,936      520.12 ms
✓ python         27,233,818      184.24 ms     12,093,228      754.05 ms     28,012,544      557.13 ms
✓ ruby           83,640,479      180.62 ms     43,502,742      761.14 ms     93,986,816      537.67 ms
✓ rust              395,048      151.08 ms        211,580      721.11 ms        401,408      504.33 ms
✓ swift         302,737,298      155.80 ms     97,671,457      718.55 ms    315,985,920      523.28 ms
✓ zig               141,688      154.25 ms         72,471      706.74 ms        147,456      517.21 ms
```

## Options

`run.sh` supports the following environment variables:

| Variable | Effect |
|----------|--------|
| `SKIP_COLIMA=1` | Skip [Colima](https://github.com/abiosoft/colima) (included by default when installed) |
| `SKIP_APPLE=1` | Skip Apple Container builds (Docker only) |
| `N_RUNS=25` | Number of benchmark runs per image (default: `10`) |

### Examples

```sh
# Docker + Apple Container + Colima (default, when Colima is installed)
./run.sh

# Docker + Apple Container only (skip Colima)
SKIP_COLIMA=1 ./run.sh

# Docker + Colima only
SKIP_APPLE=1 ./run.sh

# Docker only
SKIP_APPLE=1 SKIP_COLIMA=1 ./run.sh

# Docker only, 50 benchmark runs
SKIP_APPLE=1 SKIP_COLIMA=1 N_RUNS=50 ./run.sh
```
