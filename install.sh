# !/bin/bash

PACMAN_PARALLELDOWNLOADS=5

pacman-key --init \
&& pacman-key --populate archlinux \
&& sed 's/ParallelDownloads = \d+/ParallelDownloads = ${PACMAN_PARALLELDOWNLOADS}/g' -i /etc/pacman.conf \
&& sed 's/NoProgressBar/#NoProgressBar/g' -i /etc/pacman.conf \
&& sed -i 's/^Server = https:\/\/.*/Server = https:\/\/archlinux.c3sl.ufpr.br\/$repo\/os\/$arch/' /etc/pacman.d/mirrorlist

# Update system
pacman -Syyu --noconfirm \
    openssh \
    ; pacman -Rns $(pacman -Qtdq) \
    ; pacman -Scc --noconfirm \
    ; rm -Rf /var/cache/pacman/pkg/*


if [ -d gitlab ]
then
    mkdir -p gitlab/{config,data,logs,ssl}
fi

if [ -d gitlab-runner ]
then
    mkdir -p gitlab-runner/{config,ssl}
fi

if [ -d tmp ]
then
    mkdir -p tmp/ssl
fi