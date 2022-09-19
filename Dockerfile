FROM golang:1.19 as gobuild
RUN cd $HOME \
 && git clone https://github.com/etcd-io/etcd -b v3.5.2 \
 && cd etcd \
 && make build
RUN cd $HOME \
 && git clone https://github.com/derailed/k9s.git -b v0.25.18 \
 && cd k9s \
 && make build
RUN cd $HOME \
 && git clone https://github.com/kubernetes-sigs/cri-tools.git -b v1.25.0 \
 && cd cri-tools \
 && make crictl
RUN cd $HOME \
 && OS=$(go env GOOS); ARCH=$(go env GOARCH); curl -sSL -o cmctl.tar.gz https://github.com/cert-manager/cert-manager/releases/download/v1.7.2/cmctl-$OS-$ARCH.tar.gz \
 && tar xzf cmctl.tar.gz

FROM debian:latest
RUN apt-get update -y \
 && apt-get install -y net-tools bind9-dnsutils curl socat nmap tcpdump openssl vim ncat wget inetutils-ping whois inetutils-telnet openssh-client iproute2 jq sed grep coreutils findutils inetutils-tools inetutils-traceroute sudo bash-completion less iproute2 man-db iputils-clockdiff iputils-arping amqp-tools postgresql-client ldnsutils procps xxd
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
 && curl -LO  "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256" \
 && echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check \
 && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
 && echo 'source <(kubectl completion bash)' >>~/.bashrc
RUN curl -L https://github.com/projectcalico/calico/releases/download/v3.22.1/calicoctl-linux-amd64 -o /usr/bin/kubectl-calico \
 && chmod +x /usr/bin/kubectl-calico
RUN curl -L https://raw.githubusercontent.com/drwetter/testssl.sh/3.0/testssl.sh -o /usr/bin/testssl \
 && chmod +x /usr/bin/testssl
COPY --from=gobuild /root/etcd/bin/etcdctl /usr/bin/etcdctl
COPY --from=gobuild /root/k9s/execs/k9s /usr/bin/k9s
COPY --from=gobuild /root/cmctl /usr/bin/cmctl
COPY --from=gobuild /root/cri-tools/build/bin/crictl /usr/bin/crictl

ENTRYPOINT [ "/bin/bash", "-l" ]

