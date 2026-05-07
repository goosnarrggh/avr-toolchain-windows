FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", "-Command", "$ErrorActionPreference = 'Stop';"]

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -Uri "https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe" -OutFile "msys2.exe"; \
    ./msys2.exe -y -oc:\; \
    Remove-Item msys2.exe

COPY packages/windows.txt C:/msys64/packages-source.txt

RUN ["C:\\msys64\\usr\\bin\\bash.exe", "-lc", "set -euo pipefail; tr -d '\\r' < /packages-source.txt | sed -e 's/#.*//' -e '/^[[:space:]]*$/d' > /packages.txt; mapfile -t packages < /packages.txt; pacman --noconfirm -Syuu; pacman --noconfirm -Syuu; pacman --needed --noconfirm -Sy \"${packages[@]}\"; pacman -Q \"${packages[@]}\" | tee /toolchain_metadata.txt"]

ENV Path="C:\msys64\ucrt64\bin;C:\msys64\usr\bin;C:\Windows\System32\WindowsPowerShell\v1.0;C:\Windows\System32;C:\Windows;C:\Windows\System32\Wbem"

CMD ["avr-gcc", "--version"]
