# AVR toolchain (Windows container)

This repository builds a **Windows Server Core** Docker image with an **Atmel/Microchip AVR** cross-compilation toolchain and common build utilities, assembled on top of **MSYS2**.

The image is intended for CI (for example GitHub Actions on `windows-2022`) or any environment where you want a reproducible AVR build on Windows containers without maintaining the toolchain on the host.

## What the image includes

| Area | Details |
|------|---------|
| **Base** | `mcr.microsoft.com/windows/servercore:ltsc2022` |
| **Runtime / packaging** | [MSYS2](https://www.msys2.org/) installed under `C:\msys64`, with `C:\msys64\mingw64\bin` and `C:\msys64\usr\bin` on the machine `PATH` |
| **AVR toolchain** | `avr-gcc`, binutils, and **avr-libc** (MINGW packages: `mingw-w64-x86_64-avr-gcc`, `mingw-w64-x86_64-avr-libc`) |
| **Build tools** | CMake, Ninja, GNU Make |
| **Utilities** | **srecord** (ROM/hex manipulation and conversion) |

During the image build, installed package versions are written under the MSYS root as `toolchain_metadata.txt` (from `pacman -Q` on those packages) and echoed in the build log.

The default container command runs `avr-gcc --version` as a quick sanity check.

## Using the image

After the workflow publishes to GitHub Container Registry, pull and run:

```powershell
docker pull ghcr.io/goosnarrggh/avr-toolchain-windows:latest
docker run --rm ghcr.io/goosnarrggh/avr-toolchain-windows:latest avr-gcc --version
```

Build locally on a Windows machine with Docker in **Windows containers** mode:

```powershell
docker build -t avr-toolchain-windows:latest .
docker run --rm avr-toolchain-windows:latest cmake --version
```

## Where the software comes from

**This repository** only contains the **Dockerfile** and automation that download MSYS2, run `pacman`, and configure `PATH`. It does not vendor the compiler or libraries; those are the same packages you would get from an MSYS2 install.

To inspect or rebuild from source, use the links below.

### MSYS2 (installer, environment, and packages)

| Topic | Where to look |
|-------|----------------|
| MSYS2 project & docs | [msys2.org](https://www.msys2.org/), [github.com/msys2](https://github.com/msys2) |
| Self-extracting installer (what the Dockerfile downloads) | [msys2/msys2-installer](https://github.com/msys2/msys2-installer) |
| **MINGW** package recipes (AVR GCC, avr-libc, CMake, Ninja, srecord, etc.) | [msys2/MINGW-packages](https://github.com/msys2/MINGW-packages) — search for the package name (for example `mingw-w64-avr-gcc`) |
| **MSYS** package recipes (`make`, and other `/usr` tools) | [msys2/MSYS2-packages](https://github.com/msys2/MSYS2-packages) |

Each package directory contains a `PKGBUILD` and patches; that file lists upstream URLs and version pins.

### Upstream projects (typical sources behind those packages)

| Component | Upstream home |
|-----------|----------------|
| **GCC** (incl. AVR target support) | [GNU GCC](https://gcc.gnu.org/) — [official releases](https://ftp.gnu.org/gnu/gcc/) |
| **Binutils** | [GNU Binutils](https://www.gnu.org/software/binutils/) |
| **avr-libc** | [avrdudes/avr-libc](https://github.com/avrdudes/avr-libc) |
| **CMake** | [Kitware CMake](https://cmake.org/) — [gitlab.kitware.com/cmake/cmake](https://gitlab.kitware.com/cmake/cmake) |
| **Ninja** | [ninja-build/ninja](https://github.com/ninja-build/ninja) |
| **GNU Make** | [GNU Make](https://www.gnu.org/software/make/) |
| **srecord** | [srecord on SourceForge](https://sourceforge.net/projects/srecord/) |

For the exact tarball and version used in *your* image, open the corresponding `PKGBUILD` in **MINGW-packages** (or **MSYS2-packages**) at the commit that matches the package versions in `toolchain_metadata.txt` from your build log.
