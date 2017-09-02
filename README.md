# varnishcache

 Varnish Cache Server that runs inside a Docker container.

## How to run the server

1. Set the environment variables you wish to modify from below.
1. Prepare your default.vcl file
1. Enjoy!

The following environment variables are available:

```console
VARNISH_MALLOC (DEFAULT: 256m - For more information see Varnish - Storage backends)
VARNISH_LOG (DEFAULT: 1 - Set to 1 or 0 to enable or disable varnishncsa, for more information see Varnish - varnishncsa)
VARNISH_LOG_FORMAT (DEFAULT: %h %l %u %t "%r" %s %b "%{Referer}i" "%{User-agent}i" %{Varnish:hitmiss}x - varnishncsa log format string, for more information see Varnish - varnishncsa)
```

### Useful links

* [Varnish - Storage backends](https://varnish-cache.org/docs/5.1/users-guide/storage-backends.html "Storage backends")

* [Varnish - varnishncsa](https://varnish-cache.org/docs/5.1/reference/varnishncsa.html "varnishncsa")

## docker-compose example

 [docker-compose example](https://github.com/Mikoj/varnishcache/tree/master/examples/varnish-nginx-example "docker-compose example")

```yaml
version: '3'
services:
    varnish:
        image: mikojpl/varnishcache:latest
        restart: always
        depends_on:
            - nginx
        ports:
            - "8080:80"
        environment:
            - VARNISH_MALLOC=1g
        volumes:
            - ./default.vcl:/etc/varnish/default.vcl:ro
        networks:
            - varnish-to-nginx
    nginx:
        image: nginx:latest
        restart: always
        networks:
            - varnish-to-nginx
networks:
    varnish-to-nginx:
        driver: bridge
```

## Anything else

If you need help, have questions or bug submissions, feel free to contact me **@mikojpl** on Twitter.
