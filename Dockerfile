FROM ubuntu:20.04 as builder

LABEL Maintainer = "Evgeny Varnavskiy <varnavruz@gmail.com>"
LABEL Description="Docker image for TON (Telegram open network) node"
LABEL License="MIT License"

ARG HOST_USER_UID=1000
ARG HOST_USER_GID=1000
ENV DEBIAN_FRONTEND=noninteractive
ENV CMAKE_BUILD_PARALLEL_LEVEL=2

SHELL ["/bin/bash", "-cex -o pipefail"]

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl cargo ninja-build sudo ca-certificates build-essential cmake clang openssl libssl-dev zlib1g-dev gperf wget git

RUN groupadd --gid "$HOST_USER_GID" ton && \
    useradd --uid "$HOST_USER_UID" --gid "$HOST_USER_GID" --create-home --shell /bin/bash ton && \
    echo "ton ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
	mkdir /opt/freeton/ && \
	chown ton:ton /opt/freeton/ && \
    curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    source $HOME/.cargo/env && \
    rustup update

USER ton
WORKDIR /opt/freeton/
RUN git clone --depth 1 --recursive https://github.com/tonlabs/main.ton.dev.git
WORKDIR /opt/freeton/main.ton.dev/scripts/
RUN ./env.sh && ./build.sh


FROM ubuntu:20.04

ARG HOST_USER_UID=1000
ARG HOST_USER_GID=1000
ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-cex -o pipefail"]

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl sudo ca-certificates wget && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd --gid "$HOST_USER_GID" ton \
    && useradd --uid "$HOST_USER_UID" --gid "$HOST_USER_GID" --create-home --shell /bin/bash ton && \
    echo "ton ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
	mkdir /opt/freeton/ && \
	chown ton:ton /opt/freeton/

COPY --from=builder /opt/freeton/main.ton.dev /opt/freeton/main.ton.dev
USER ton
WORKDIR /opt/freeton/main.ton.dev/scripts/
RUN ./setup.sh && \
    wget https://github.com/tonlabs/tonos-cli/releases/download/v0.1.6-rc/tonos-cli_v0.1.6_linux.tar.gz && \
    tar xvf ./*cli*.tar.gz && \
    rm -rf /var/lib/apt/lists/*
COPY entrypoint.sh .
EXPOSE 43678 43679

ENTRYPOINT ["./entrypoint.sh"]
