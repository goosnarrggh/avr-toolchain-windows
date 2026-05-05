# STAGE I: Build on the server core.
# Use official Microsoft base for the highest level of trust
FROM mcr.microsoft.com/windows/servercore:ltsc2022 AS builder

# Set PowerShell as the default shell for setup
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

# Layer 1: MSYS2 Installation
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -Uri "https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe" -OutFile "msys2.exe"; \
    ./msys2.exe -y -oc:\; \
    Remove-Item msys2.exe

COPY packages-win.txt C:/msys64/packages.txt

# LAYER 2: Update, Install, and Metadata
# We install: avr-gcc, avr-libc, cmake, ninja, make, and srecord
RUN C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -Syuu'; \
    C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -Syuu'; \
    C:\msys64\usr\bin\bash.exe -lc 'pacman --needed --noconfirm -Sy $(cat /packages.txt)'; \
    C:\msys64\usr\bin\bash.exe -lc 'pacman -Q $(cat /packages.txt) | tee /toolchain_metadata.txt'

# STAGE II: Copy essentials over to the Nano server
FROM mcr.microsoft.com/windows/nanoserver:ltsc2022

# Copy ONLY the UCRT64 hierarchy (approx. 600-800MB)
COPY --from=builder C:/msys64/ucrt64 C:/msys64/ucrt64
COPY --from=builder C:/msys64/toolchain_metadata.txt C:/msys64/toolchain_metadata.txt

# Set the System Path to include our new toolchain
ENV PATH="C:\msys64\ucrt64\bin;${PATH}"

# Smoke test each entry point
RUN avr-gcc --version && \
    avr-as --version && \
    avr-ld --version && \
    cmake --version && \
    ninja --version && \
    mingw32-make --version && \
    srec_cat --version

# Define the entrypoint to verify the toolchain
CMD ["avr-gcc", "--version"]
