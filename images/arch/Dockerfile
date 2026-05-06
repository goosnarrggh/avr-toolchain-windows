FROM archlinux:base

COPY packages/toolchain.txt /tmp/toolchain.txt

RUN set -eux; \
    packages="$(tr -d '\r' < /tmp/toolchain.txt | sed -e 's/#.*//' -e '/^[[:space:]]*$/d')"; \
    pacman -Syu --noconfirm --needed $packages; \
    ln -sf /usr/bin/make /usr/local/bin/mingw32-make; \
    pacman -Scc --noconfirm; \
    rm -f /tmp/toolchain.txt

CMD ["avr-gcc", "--version"]
