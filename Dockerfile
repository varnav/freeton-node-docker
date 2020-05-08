FROM ubuntu:18.04 as builder

LABEL Maintainer = "Evgeny Varnavskiy <varnavruz@gmail.com>"
LABEL Description="Docker image for TON (Telegram open network) node"
LABEL License="MIT License"

ARG HOST_USER_UID=1000
ARG HOST_USER_GID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV CMAKE_BUILD_PARALLEL_LEVEL=2

RUN set -ex && \
    apt-get update && \
    apt-get install --no-install-recommends -y cargo ninja-build sudo ca-certificates build-essential cmake clang openssl libssl-dev zlib1g-dev gperf wget git && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --gid "$HOST_USER_GID" ton \
    && useradd --uid "$HOST_USER_UID" --gid "$HOST_USER_GID" --create-home --shell /bin/bash ton && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
	mkdir /opt/freeton/ && \
	chown ton:ton /opt/freeton/

USER ton
WORKDIR /opt/freeton
RUN git clone --depth 1 --recursive https://github.com/tonlabs/main.ton.dev.git
RUN cd main.ton.dev/scripts && \
./env.sh && \
./build.sh && \
./setup.sh

EXPOSE 43678 43679

ENTRYPOINT ["./run.sh"]
