# AVR toolchain containers

This repository builds container images with an **Atmel/Microchip AVR** cross-compilation toolchain and common build utilities.

The images are intended for CI or any environment where you want a reproducible AVR build without maintaining the toolchain on the host.

## What the image includes

| Image | Base | Package source |
|-------|------|----------------|
| Windows | `mcr.microsoft.com/windows/servercore:ltsc2022` | MSYS2 UCRT64 |
| Arch Linux | `archlinux:base` | Arch Linux repositories plus AUR for SRecord |

Both images include:

- `avr-gcc`, AVR binutils, and `avr-libc`
- CMake, Ninja, and GNU Make
- SRecord (`srec_cat`, `srec_cmp`, `srec_info`)

The Windows package list is maintained in `packages/windows.txt` using the full MSYS2 UCRT64 package names.

The Arch image uses `packages/arch-official.txt` for packages available from the official Arch Linux repositories and `packages/arch-aur.txt` for packages that must be built from AUR. SRecord is currently in AUR, so the Arch Dockerfile builds it from the upstream AUR `PKGBUILD` during the image build.

The workflow publishes stable tags for each platform and detailed tags that include the major.minor or major.minor.patch versions of the AVR compiler, binutils, and C library packages. For example, if the installed packages are `avr-gcc` 15.2.0, `avr-binutils` 2.46, and `avr-libc` 2.3.1, the workflow also tags images as:

```txt
servercore-ltsc2022-avrgcc15.2.0-binutils2.46-avrlibc2.3.1
arch-avrgcc15.2.0-binutils2.46-avrlibc2.3.1
```

Those detailed tags are derived from the packages installed in each image, so the Windows and Arch tags can differ if their upstream package repositories carry different versions.

The default container command runs `avr-gcc --version` as a quick sanity check.

## Using the image

After the workflow publishes to GitHub Container Registry, pull and run:

```powershell
docker pull ghcr.io/goosnarrggh/avr-toolchain-windows:servercore-ltsc2022
docker run --rm ghcr.io/goosnarrggh/avr-toolchain-windows:servercore-ltsc2022 avr-gcc --version
```

The `latest` tag is also assigned to the Windows Server Core image for compatibility. Prefer the detailed tags when you need to protect downstream CI from AVR toolchain version changes.

Build locally on a Windows machine with Docker in **Windows containers** mode:

```powershell
docker build -f images/windows/Dockerfile -t avr-toolchain-windows:servercore-ltsc2022 .
docker run --rm avr-toolchain-windows:servercore-ltsc2022 cmake --version
```

Build the Arch Linux image with Docker in Linux containers mode:

```sh
docker build -f images/arch/Dockerfile -t avr-toolchain-windows:arch .
docker run --rm avr-toolchain-windows:arch cmake --version
```

Run the shared AVR smoke project:

```powershell
docker run --rm `
  -v "${PWD}\tests\hello:C:\hello" `
  avr-toolchain-windows:servercore-ltsc2022 `
  C:\Windows\System32\cmd.exe /S /C "cmake -S C:\hello -B C:\build -G Ninja -DCMAKE_TOOLCHAIN_FILE=C:\hello\avr-toolchain.cmake && cmake --build C:\build"
```

```sh
docker run --rm \
  -v "$PWD/tests/hello:/hello:ro" \
  avr-toolchain-windows:arch \
  sh -c 'cmake -S /hello -B /build -G Ninja -DCMAKE_TOOLCHAIN_FILE=/hello/avr-toolchain.cmake && cmake --build /build'
```

## Where the software comes from

**This repository** only contains Dockerfiles, package manifests, and automation that invoke upstream package managers. It does not vendor the compiler or libraries; those are the same packages you would get from MSYS2 or Arch Linux.

To inspect or rebuild from source, use the links below.

### MSYS2 (installer, environment, and packages)

| Topic | Where to look |
|-------|----------------|
| MSYS2 project & docs | [msys2.org](https://www.msys2.org/), [github.com/msys2](https://github.com/msys2) |
| Self-extracting installer (what the Dockerfile downloads) | [msys2/msys2-installer](https://github.com/msys2/msys2-installer) |
| **MINGW/UCRT64** package recipes (AVR GCC, avr-libc, CMake, Ninja, srecord, etc.) | [msys2/MINGW-packages](https://github.com/msys2/MINGW-packages) — search for the package name (for example `mingw-w64-avr-gcc`) |
| **MSYS** package recipes (`make`, and other `/usr` tools) | [msys2/MSYS2-packages](https://github.com/msys2/MSYS2-packages) |

### Arch Linux packages

| Topic | Where to look |
|-------|---------------|
| Arch package search | [archlinux.org/packages](https://archlinux.org/packages/) |
| Packaging source | [gitlab.archlinux.org/archlinux/packaging/packages](https://gitlab.archlinux.org/archlinux/packaging/packages) |
| AUR package search | [aur.archlinux.org/packages](https://aur.archlinux.org/packages) |

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
