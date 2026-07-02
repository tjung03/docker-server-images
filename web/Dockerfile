FROM rockylinux:9

RUN yum -y install httpd mod_ssl && yum clean all

RUN sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

RUN mkdir -p /etc/pki/tls/certs /etc/pki/tls/private && \
    openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/pki/tls/private/server.key \
    -out /etc/pki/tls/certs/server.crt \
    -subj "/C=KR/ST=Seoul/L=Seoul/O=infra-web/CN=myweb"

COPY ssl.conf /etc/httpd/conf.d/ssl.conf

# index.html error.html .htaccess
ADD src.tar /var/www/html  

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
