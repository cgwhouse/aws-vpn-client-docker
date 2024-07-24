FROM ubuntu:20.04 AS builder

ARG openvpn_version="2.5.1"

WORKDIR /

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  curl \
  ca-certificates \
  automake \
  unzip \
  build-essential \
  autoconf \
  libgnutls28-dev \
  libgnutls28-dev \
  liblzo2-dev \
  libpam0g-dev \
  libtool \
  libssl-dev \
  net-tools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/OpenVPN/openvpn/archive/v${openvpn_version}.zip -o openvpn.zip && \
  unzip openvpn.zip && \
  mv openvpn-${openvpn_version} openvpn

COPY openvpn-v${openvpn_version}-aws.patch openvpn

WORKDIR /openvpn

RUN patch -p1 < openvpn-v${openvpn_version}-aws.patch && \
  autoreconf -i -v -f && \
  ./configure && \
  make

WORKDIR /

RUN curl -L https://golang.org/dl/go1.15.4.linux-amd64.tar.gz -o go.tar.gz && \
  tar -C /usr/local -xzf go.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

COPY server.go .

RUN go build server.go

FROM ubuntu:20.04 AS final

ENV TZ="America/New_York"
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  dnsutils \
  liblzo2-dev \
  openssl \
  net-tools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder /openvpn/src/openvpn/openvpn /openvpn
COPY --from=builder /server /server
COPY entrypoint.sh /

COPY update-resolv-conf /etc/openvpn/scripts/

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
