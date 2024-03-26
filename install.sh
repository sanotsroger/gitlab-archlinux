# !/bin/bash

PACMAN_PARALLELDOWNLOADS=5

pacman-key --init \
&& pacman-key --populate archlinux \
&& sed 's/ParallelDownloads = \d+/ParallelDownloads = ${PACMAN_PARALLELDOWNLOADS}/g' -i /etc/pacman.conf \
&& sed 's/NoProgressBar/#NoProgressBar/g' -i /etc/pacman.conf \
&& sed -i 's/^Server = https:\/\/.*/Server = https:\/\/archlinux.c3sl.ufpr.br\/$repo\/os\/$arch/' /etc/pacman.d/mirrorlist

# Update system
pacman -Syyuu --noconfirm \
    ; pacman -Rns $(pacman -Qtdq) \
    ; pacman -Scc --noconfirm \
    ; rm -Rf /var/cache/pacman/pkg/*


if [ ! -d "gitlab" ]
then
    mkdir -p gitlab/{config,data,logs,ssl}
fi

if [ ! -d "gitlab-runner" ]
then
    mkdir -p gitlab-runner/{config,ssl}
fi

if [ ! -d "tmp" ]
then
    mkdir -p tmp/ssl
fi

# Install Docker
pacman -S --noconfirm \
    docker \
    docker-compose

systemctl start docker.service

systemctl enable docker.service

sudo usermod -aG docker $

# Generate certificates for https
openssl genrsa -out tmp/ssl/ca.key 4096

openssl req -new -x509 -days 3650 \
    -key tmp/ssl/ca.key \
    -out tmp/ssl/ca.crt

openssl req -newkey rsa:4096 -nodes \
    -keyout tmp/ssl/server.key \
        -out tmp/ssl/server.csr

openssl x509 -req -extfile <(printf "subjectAltName=DNS:githomelab,DNS:githomelab.local") \
    -days 3650 \
    -in tmp/ssl/server.csr \
    -CA tmp/ssl/ca.crt \
    -CAkey tmp/ssl/ca.key \
    -CAcreateserial -out tmp/ssl/server.crt

	