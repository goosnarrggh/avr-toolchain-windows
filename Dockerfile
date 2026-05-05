# Use official Microsoft base for the highest level of trust
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Set PowerShell as the default shell for setup
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';"]

# 1. Download the MSYS2 self-extracting archive directly from their releases
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest -Uri "https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.sfx.exe" -OutFile "msys2.exe"; \
    ./msys2.exe -y -oc:\; \
    Remove-Item msys2.exe

# 2. Copy the list from your Git repo into the MSYS2 root
COPY packages-win.txt C:/msys64/packages.txt

# 3. Read the file and write it back out to ensure clean line endings
RUN Get-Content 'C:\msys64\packages.txt' | Set-Content -Path 'C:\msys64\packages_clean.txt' -Encoding Ascii

# 4. Update MSYS2 and install the toolchain + extra utilities
# We install: avr-gcc, avr-libc, cmake, ninja, make, and srecord
RUN C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -Syuu'; \
    C:\msys64\usr\bin\bash.exe -lc 'pacman --noconfirm -Syuu'; \
    C:\msys64\usr\bin\bash.exe -lc 'cat /packages_clean.txt | xargs pacman --needed --noconfirm -S'

# 3. Integrate MSYS2 into the Windows System Path
# This allows 'avr-gcc' to be called directly from standard Windows prompts
RUN $newPath = 'C:\msys64\mingw64\bin;C:\msys64\usr\bin;' + [Environment]::GetEnvironmentVariable('Path', 'Machine'); \
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine')

# 4. GENERATE METADATA FILE
# This queries the installed versions of your key tools and saves them to a file.
# It also prints them to the build log so you can see them in your CI output.
RUN C:\msys64\usr\bin\bash.exe -lc 'cat /packages_clean.txt | xargs pacman -Q > /toolchain_metadata.txt'

# 5: Read it back using PowerShell
RUN Get-Content C:\msys64\toolchain_metadata.txt

# Define the entrypoint to verify the toolchain
CMD ["avr-gcc", "--version"]
