# Telegram Open Network Node

![Validate code](https://github.com/varnav/freeton-node-docker/workflows/Validate%20code/badge.svg)[![Docker Pulls](https://img.shields.io/docker/pulls/varnav/freeton-node.svg)](https://hub.docker.com/r/varnav/freeton-node)

Dockerfile for FreeTON Node

https://freeton.org/

#### Open firewall

`ufw allow 43679/udp`

#### Build

It's recommended to build this on same machine where you plan to run it.

```bash
git clone https://github.com/varnav/freeton-node-docker.git
cd freeton-node-docker
docker build -t varnav/freeton-node .
```

#### Run interactively

```bash
docker run --rm -it --name freeton-testnet -v freeton-db:/var/ton-work/db -e "CONSOLE_PORT=43678" -e "LITESERVER=true" -e "LITE_PORT=43679" -p 43678:43678 -p 43679:43679 varnav/freeton-node
```

#### Run as daemon

```bash
docker run -d --restart=unless-stopped --name freeton-testnet -v freeton-db:/var/ton-work/db -e "CONSOLE_PORT=43678" -e "LITESERVER=true" -e "LITE_PORT=43679" -p 43678:43678 -p 43679:43679 varnav/freeton-node
```

#### Clean all

```bash
docker rm --force freeton-testnet
docker volume rm freeton-db
docker image rm varnav/freeton-node
```

### Run with kubernetes

```
kubectl apply -f .\kubernetes-deployment.yml
kubectl expose deployment freeton-node --type LoadBalancer
```

#### License

MIT

#### Thanks to

akme  
copperbits