# Docker DNS-gen

dns-gen sets up a container running Dnsmasq and [docker-gen].
docker-gen generates a configuration for Dnsmasq and reloads it when containers are
started and stopped.

reference project [docker-dns-gen]，use template:

    {{ $domain := or ($.Env.DOMAIN_TLD) "docker" }}
    {{range $key, $value := .}}
    address=/{{ $value.Hostname }}/{{$value.IP}}
    address=/{{ $value.Name }}.{{$domain}}/{{$value.IP}}
    address=/{{ $value.Hostname }}.{{$domain}}/{{$value.IP}}
    {{end}}

## build image

    $ docker build -t jiadx/docker-dns-gen --rm .

### Simple usage
start dns-gen ：

    docker run -d --name dns-gen \
         --restart always \
         --publish 171.17.42.1:53:53/udp \
         --volume /var/run/docker.sock:/var/run/docker.sock \
         jiadx/docker-dns-gen
`171.17.42.1` is docker0 bridge IP.

when you start container:

    docker run -ti --rm -h hostname1 --name host1  centos:6.7 bash
the generated /etc/dnsmasq.conf looks like:

      address=/hostname1/171.17.0.13
      address=/host1.docker/171.17.0.13
      address=/hostname1.docker/171.17.0.13

reference [docker-dns-gen]。

  [docker-dns-gen]: https://github.com/jderusse/docker-dns-gen
  [docker-gen]: https://github.com/jwilder/docker-gen