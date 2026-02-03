# Imagem base oficial da Microsoft para DevContainers
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Instalação de utilitários de rede essenciais para Troubleshooting
# (Ping, DNS utils, IP route) - debug de containers
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends iputils-ping dnsutils iproute2