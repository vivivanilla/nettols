FROM golang:1.19 as gobuild
RUN cd $HOME \
 && git clone https://github.com/etcd-io/etcd -b v3.5.5 \
 && cd etcd \
 && make build
RUN cd $HOME \
 && git clone https://github.com/derailed/k9s.git -b v0.26.3 \
 && cd k9s \
 && make build
RUN cd $HOME \
 && git clone https://github.com/kubernetes-sigs/cri-tools.git -b v1.25.0 \
 && cd cri-tools \
 && make crictl
RUN cd $HOME \
 && git clone https://github.com/projectcalico/calico.git -b v3.24.1 \
 && cd calico/calicoctl \
 && make DOCKER_RUN="" CALICO_BUILD="" build
RUN cd $HOME \
 && OS=$(go env GOOS); ARCH=$(go env GOARCH); curl -sSL -o cmctl.tar.gz https://github.com/cert-manager/cert-manager/releases/download/v1.7.2/cmctl-$OS-$ARCH.tar.gz \
 && tar xzf cmctl.tar.gz

FROM debian:latest
RUN apt-get update -y \
 && apt-get install -y net-tools bind9-dnsutils curl socat nmap tcpdump openssl vim ncat wget inetutils-ping whois inetutils-telnet openssh-client iproute2 jq sed grep coreutils findutils inetutils-tools inetutils-traceroute sudo bash-completion less iproute2 man-db iputils-clockdiff iputils-arping amqp-tools postgresql-client ldnsutils procps xxd zsh zplug
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
 && curl -LO  "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" \
 && echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check \
 && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
COPY --from=gobuild /root/etcd/bin/etcdctl /usr/bin/etcdctl
COPY --from=gobuild /root/k9s/execs/k9s /usr/bin/k9s
COPY --from=gobuild /root/cmctl /usr/bin/cmctl
COPY --from=gobuild /root/calico/calicoctl/bin/calicoctl-linux-amd64 /usr/bin/calicoctl
COPY --from=gobuild /root/cri-tools/build/bin/crictl /usr/bin/crictl
COPY .zshrc /root/.zshrc

ENTRYPOINT [ "/bin/zsh", "-l" ]

