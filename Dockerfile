FROM ubuntu:20.04 

RUN apt-get update && apt -y install \
    scdaemon \
    gnupg2 \
    makepasswd \
    # yubikey-manager \
    # systemctl \
    && rm -rf /var/lib/apt/lists/*
