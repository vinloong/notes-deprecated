```dockerfile
FROM alpine:latest

ENV LANG=C.UTF-8

RUN sed -i "s@https://dl-cdn.alpinelinux.org/@https://repo.huaweicloud.com/@g" /etc/apk/repositories \
    && ALPINE_GLIBC_PKG_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" \
    && ALPINE_GLIBC_PKG_VERSION="2.34-r0" \
    && ALPINE_GLIBC_PKG_NAME="glibc-${ALPINE_GLIBC_PKG_VERSION}.apk" \
    && ALPINE_GLIBC_PKG_BIN_NAME="glibc-bin-${ALPINE_GLIBC_PKG_VERSION}.apk" \
    && ALPINE_GLIBC_PKG_I18N_NAME="glibc-i18n-${ALPINE_GLIBC_PKG_VERSION}.apk" \    
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget "${ALPINE_GLIBC_PKG_BASE_URL}/${ALPINE_GLIBC_PKG_VERSION}/${ALPINE_GLIBC_PKG_NAME}" \
            "${ALPINE_GLIBC_PKG_BASE_URL}/${ALPINE_GLIBC_PKG_VERSION}/${ALPINE_GLIBC_PKG_BIN_NAME}" \
            "${ALPINE_GLIBC_PKG_BASE_URL}/${ALPINE_GLIBC_PKG_VERSION}/${ALPINE_GLIBC_PKG_I18N_NAME}" \
    && apk add --no-cache ${ALPINE_GLIBC_PKG_NAME} ${ALPINE_GLIBC_PKG_BIN_NAME} ${ALPINE_GLIBC_PKG_I18N_NAME} \
    && (/usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true) \
    && echo "export LANG=$LANG" > /etc/profile.d/locale.sh \
    && apk add --no-cache tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata \
    && rm ${ALPINE_GLIBC_PKG_NAME} ${ALPINE_GLIBC_PKG_BIN_NAME} ${ALPINE_GLIBC_PKG_I18N_NAME} 
```
