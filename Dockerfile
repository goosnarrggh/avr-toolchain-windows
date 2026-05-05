# Use official Microsoft base for the highest level of trust
FROM mcr.microsoft.com/windows/servercore:ltsc2022

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

# Path Setup
ENV PATH="C:\msys64\mingw64\bin;C:\msys64\usr\bin;${PATH}"


# Define the entrypoint to verify the toolchain
CMD ["avr-gcc", "--version"]
