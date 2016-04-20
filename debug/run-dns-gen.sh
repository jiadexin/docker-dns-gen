#!/usr/bin/env sh
docker run -ti --rm \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume ../config:/opt/config \
  --entrypoint /opt/config/show-dns.sh \
  jderusse/dns-gen
