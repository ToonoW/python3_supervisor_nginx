FROM daocloud.io/library/python:3.6-alpine

MAINTAINER jinwen

# -- Install Pipenv:
ENV LANG=en_US.UTF-8 \
    TIME_ZONE=Asia/Shanghai


RUN set -ex && \
    echo 'https://mirror.tuna.tsinghua.edu.cn/alpine/v3.8/main' > /etc/apk/repositories && \
    echo 'https://mirror.tuna.tsinghua.edu.cn/alpine/v3.8/community' >> /etc/apk/repositories && \
    apk update && apk add --no-cache supervisor nginx

RUN pip install --upgrade pip && pip config set gloabl.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple pipenv


# -- Create work dir and log dir
ONBUILD RUN mkdir -p /app
ONBUILD WORKDIR /app
ONBUILD ADD . /app
ONBUILD RUN mkdir -p /data/nginx
ONBUILD RUN mkdir -p /data/supervisor

# -- Add config file
ONBUILD ADD nginx.conf /etc/nginx/nginx.conf
ONBUILD ADD app.conf /etc/nginx/sites-available/app.conf
ONBUILD RUN ln -s /etc/nginx/sites-available/app.conf /etc/nginx/conf.d/
ONBUILD RUN rm -f /etc/nginx/conf.d/default.conf

# -- Expose
ONBUILD EXPOSE 80

# -- Entrypoint
ONBUILD ENTRYPOINT ["/usr/bin/supervisord"]
ONBUILD CMD ["-n"]