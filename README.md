# Docker DNS-gen

dns-gen sets up a container running Dnsmasq and [docker-gen].
docker-gen generates a configuration for Dnsmasq and reloads it when containers are
started and stopped.

reference project [docker-dns-gen]，use template:

    {{ define "host" }}
            {{ $host := .Host }}
            {{ $tld := .Tld }}
            {{ if eq $tld "" }}
                {{ range $index, $network := .Container.Networks }}
                    {{ if ne $network.IP "" }}
        address=/{{ $host }}/{{ $network.IP }}
                    {{ end }}
                {{ end }}
            {{ else }}
                {{ range $index, $network := .Container.Networks }}
                    {{ if ne $network.IP "" }}
        address=/{{ $host }}.{{ $tld }}/{{ $network.IP }}
        address=/{{ $host }}.{{ $network.Name }}.{{ $tld }}/{{ $network.IP }}
                    {{ end }}
                {{ end }}
            {{ end }}
        {{ end }}

        {{ $tld := or ($.Env.DOMAIN_TLD) "docker" }}
        {{ range $index, $container := $ }}
            {{ template "host" (dict "Container" $container "Host" $container.Hostname "Tld" $tld) }}
            {{ template "host" (dict "Container" $container "Host" $container.Name "Tld" $tld) }}
        {{ end }}

        {{ range $host, $containers := groupByMulti $ "Env.DOMAIN_NAME" "," }}
            {{ range $index, $container := $containers }}
                {{ template "host" (dict "Container" $container "Host" (print $host) "Tld" "") }}
            {{ end }}
        {{ end }}
And support `tcp` docker api endpoint .

# build image

    $ docker build -t jiadx/docker-dns-gen --rm .

# Simple usage
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

      address=/host1.docker/171.17.0.13
      address=/hostname1.docker/171.17.0.13

reference [docker-dns-gen]。

# support user-defined network
create docker network:

    docker network create --driver overlay --subnet=173.17.0.0/24 my-net
start container with user-defined network:

    docker run -ti --rm -h hostname1 --name host1 --net my-net  centos:6.7 bash
the generated /etc/dnsmasq.conf looks like:

      address=/host1.docker/173.17.0.13
      address=/host1.my-net.docker/173.17.0.13
      address=/hostname1.docker/173.17.0.13
      address=/hostname1.my-net.docker/173.17.0.13

  [docker-dns-gen]: https://github.com/jderusse/docker-dns-gen
  [docker-gen]: https://github.com/jwilder/docker-gen