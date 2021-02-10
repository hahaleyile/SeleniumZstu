FROM python:3.8-alpine

ENV TZ="CST-8" \
    CHROME_BIN=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/lib/chromium/

COPY Main.py cronfile zstu.sh /app/

WORKDIR /app

RUN \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/main" >> /etc/apk/repositories && \
    sed -i 's?\(http://\).*\(/alpine.*\)?\1mirrors.aliyun.com\2?g' /etc/apk/repositories && \
    sed -i '/dotenv/d' /app/Main.py && \
    sed -i '/binary_location/d' /app/Main.py && \
    apk upgrade -U -a && \
    apk add --no-cache \
        mailx \
        postfix \
        chromium-chromedriver \
        chromium \
        harfbuzz \
        freetype \
        ttf-freefont \
        font-noto-emoji \
        wqy-zenhei && \
        # 需要添加中文字体来保证截图的显示正确
    rm -rf /var/cache/* && \
    mkdir /var/cache/apk && \
    mkdir /logs && \
    mkdir /Appdata && \
    \
    mkdir ~/.pip && \
    echo -e \
    "[global]\n\
    timeout = 6000\n\
    index-url = https://pypi.tuna.tsinghua.edu.cn/simple\n\
    trusted-host = pypi.tuna.tsinghua.edu.cn" \
    > ~/.pip/pip.conf && \
    pip install --no-cache-dir -U \
        pip \
        selenium && \
    \
    #apk add --virtual mypacks tzdata && \
    #cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    #apk del mypacks && \
    crontab cronfile

CMD crond -f