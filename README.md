# OpenVPN AWS VPN Linux Client in Docker

This is a Docker implementation of the [original](https://github.com/samm-git/aws-vpn-client)
AWS VPN client PoCwith OpenVPN using SAML authentication.
The goal is to have an easy to consume Linux client.

See [the original blog post](https://smallhacks.wordpress.com/2020/07/08/aws-client-vpn-internals/)
for the implementation details.

## Content of the repository

- [openvpn-v2.4.9-aws.patch](openvpn-v2.4.9-aws.patch) - patch required to build
  AWS compatible OpenVPN v2.4.9, based on the
  [AWS source code](https://amazon-source-code-downloads.s3.amazonaws.com/aws/clientvpn/osx-v1.2.5/openvpn-2.4.5-aws-2.tar.gz)
  (thanks to @heprotecbuthealsoattac) for the link.
- [openvpn-v2.5.1-aws.patch](openvpn-v2.5.1-aws.patch) - patch
  for OpenVPN v2.5.1, based on the
  [AWS source code](https://amazon-source-code-downloads.s3.amazonaws.com/aws/clientvpn/osx-v1.2.5/openvpn-2.4.5-aws-2.tar.gz)
  (thanks to @heprotecbuthealsoattac) for the link.
- [server.go](server.go) - Go server to listen on [http://127.0.0.1:35001] and save
  SAML Post data to the file.
- [entrypoint.sh](entrypoint.sh) - bash wrapper to run OpenVPN.
  It runs OpenVPN first time to get SAML Redirect and open
  browser and second time with actual SAML response.
- [Dockerfile](Dockerfile) - for building the docker image.
- [docker-compose.yml](docker-compose.yml) - for running the image properly.

## How to use

1. Place AWS configuration file at the same folder of
   `docker-compose.yml`, naming it `vpn.conf`
2. Execute `docker-compose up` (Better to not use `-d` option,
   for getting the login URL in the logs and stopping the container in a easier way)
