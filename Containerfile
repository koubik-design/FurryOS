# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# Base Image - Zvolen Bazzite pro PC s grafickou kartou NVIDIA
FROM ghcr.io/ublue-os/bazzite-nvidia:stable

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

# VLASTNÍ ÚPRAVY: Instalace dodatečných aplikací do systému
RUN rpm-ostree install neovim htop && \
    rpm-ostree cleanup -m

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
