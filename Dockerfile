FROM registry.access.redhat.com/ubi8/ubi:latest
WORKDIR /tmp
ARG NGINX_VERSION=1.22.1
RUN dnf install -y gcc make unzip ca-certificates curl gnupg2 pcre-devel openssl-devel zlib-devel patch --nobest --setopt=install_weak_deps=False --skip-broken && \
    curl -fsS -LO https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    curl -fsS -LO https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/get/08a395c66e42.zip && \
    tar -zxvf nginx-${NGINX_VERSION}.tar.gz && \
    unzip 08a395c66e42.zip && \
    rm 08a395c66e42.zip && \
    cd nginx-${NGINX_VERSION} && \
    cd /tmp/nginx-${NGINX_VERSION} && \
    ./configure --add-module=/tmp/nginx-goodies-nginx-sticky-module-ng-08a395c66e42 \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-cc-opt='-g -O2 -ffile-prefix-map=/data/builder/debuild/nginx-${NGINX_VERSION}/debian/debuild-base/nginx-${NGINX_VERSION}=. -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' \
    --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' &&\
    make && make install && \
    dnf remove -y gcc make patch  --nobest && \
    rm -rf /var/cache/yum/* &&\
    rm -rf /tmp/* &&\
    rm -rf /etc/nginx/nginx.conf &&\
    rm -rf /etc/nginx/html/* &&\
    mkdir /var/cache/nginx/
ENV PATH="/usr/local/nginx/sbin:$PATH"
EXPOSE 80 443
RUN useradd -r -s /bin/false nginx
#COPY nginx.conf /etc/nginx/
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]