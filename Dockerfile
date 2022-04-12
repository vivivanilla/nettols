FROM debian:latest
RUN apt-get update -y \
 && apt-get install -y net-tools bind9-dnsutils curl socat nmap tcpdump openssl vim ncat wget inetutils-ping whois inetutils-telnet openssh-client iproute2 jq sed grep coreutils findutils inetutils-tools inetutils-traceroute

ENTRYPOINT [ "/bin/bash" ]

