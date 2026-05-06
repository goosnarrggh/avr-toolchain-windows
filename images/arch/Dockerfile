FROM archlinux:base

COPY packages/arch-official.txt /tmp/arch-official.txt
COPY packages/arch-aur.txt /tmp/arch-aur.txt

RUN set -eux; \
 official_packages="$(tr -d '\r' < /tmp/arch-official.txt | sed -e 's/#.*//' -e '/^[[:space:]]*$/d')"; \
 aur_packages="$(tr -d '\r' < /tmp/arch-aur.txt | sed -e 's/#.*//' -e '/^[[:space:]]*$/d')"; \
 pacman -Syu --noconfirm --needed $official_packages base-devel git sudo; \
 useradd --create-home --shell /bin/bash builder; \
 printf 'builder ALL=(ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/builder; \
 chmod 0440 /etc/sudoers.d/builder; \
 for package in $aur_packages; do \
 su builder -c "cd /tmp && git clone https://aur.archlinux.org/${package}.git && cd ${package} && makepkg --syncdeps --noconfirm --needed"; \
 pacman -U --noconfirm /tmp/${package}/*.pkg.tar.zst; \
 done; \
 ln -sf /usr/bin/make /usr/local/bin/mingw32-make; \
 pacman -Scc --noconfirm; \
 userdel --remove builder; \
 rm -rf /tmp/arch-official.txt /tmp/arch-aur.txt /tmp/srecord /etc/sudoers.d/builder

CMD ["avr-gcc", "--version"]
