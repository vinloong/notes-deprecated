```dockerfile
FROM frolvlad/alpine-glibc:alpine-3.5

MAINTAINER xxx "xxx@xxx.com"

ADD recv /usr/local/bin
RUN chmod +x /usr/local/bin/recv

EXPOSE 7002

CMD ["-addr",":7002","-brokers","192.168.0.201:6667,192.168.0.202:6667,192.168.0.211:6667,192.168.0.212:6667,192.168.0.213:6667,192.168.0.214:6667"]

ENTRYPOINT ["recv"]
```


