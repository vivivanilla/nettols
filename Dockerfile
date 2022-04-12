FROM golang:1.17 as gobuild
RUN cd $HOME \
 && git clone https://github.com/etcd-io/etcd -b v3.5.2 \
 && cd etcd \
 && make build
RUN cd $HOME \
 && git clone https://github.com/derailed/k9s.git -b v0.25.18 \
 && cd k9s \
 && make build

FROM debian:latest
RUN apt-get update -y \
 && apt-get install -y net-tools bind9-dnsutils curl socat nmap tcpdump openssl vim ncat wget inetutils-ping whois inetutils-telnet openssh-client iproute2 jq sed grep coreutils findutils inetutils-tools inetutils-traceroute sudo bash-completion less
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
 && curl -LO  "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" \
 && echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check \
 && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
 && echo 'source <(kubectl completion bash)' >>~/.bashrc
COPY --from=gobuild /root/etcd/bin/etcdctl /usr/bin/etcdctl
COPY --from=gobuild /root/k9s/execs/k9s /usr/bin/k9s

ENTRYPOINT [ "/bin/bash", "-l" ]

