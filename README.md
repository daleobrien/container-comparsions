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
bun              98,127,649      148.57 ms     39,962,730      815.62 ms     98,795,520      542.44 ms
c                       832      142.66 ms          1,519      697.54 ms          8,192      506.70 ms
cpp                     832      143.90 ms          1,519      698.44 ms          8,192      509.05 ms
dotnet            1,385,640      140.86 ms        656,747      769.57 ms      1,392,640      530.68 ms
go                1,441,944      151.21 ms        603,357      717.80 ms      1,449,984      493.76 ms
haskell           1,064,856      140.83 ms        374,995      777.76 ms      1,069,056      525.17 ms
java             47,333,302      140.19 ms     13,512,447      699.44 ms     51,675,136      508.37 ms
node            117,987,529      145.36 ms     47,441,021      724.70 ms    118,657,024      526.05 ms
php             105,603,450      151.69 ms     41,276,045      705.58 ms    109,223,936      534.16 ms
python           27,233,818      173.13 ms     12,093,228      752.09 ms     28,012,544      555.82 ms
ruby             83,640,479      164.98 ms     43,502,742      744.87 ms     93,986,816      525.06 ms
rust                395,048      142.87 ms        211,580      722.67 ms        401,408      515.08 ms
swift           302,737,298      148.35 ms     97,671,457      718.01 ms    315,985,920      512.01 ms
zig                 128,664      144.69 ms         65,066      723.94 ms        135,168      522.14 ms
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
