FROM hahaleyile/selenium_chrome_python

COPY Main.py cronfile zstu.sh /app/

WORKDIR /app

RUN \
    sed -i '/dotenv/d' /app/Main.py && \
    sed -i '/binary_location/d' /app/Main.py && \
    apk upgrade -U -a && \
    apk add --no-cache \
        mailx \
        postfix && \
    rm -rf /var/cache/* && \
    mkdir /var/cache/apk && \
    mkdir /logs && \
    mkdir /Appdata && \
    crontab cronfile

CMD ["/usr/sbin/crond","-f"]