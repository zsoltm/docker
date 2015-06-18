FROM zsoltm/debian-armhf:jessie

# docker run -p 80:80 -v `pwd`:/usr/share/nginx/html:ro -d 

COPY nginx_1.9.2-1~jessie_armhf.deb /
ENV NGINX_VERSION 1.9.2-1~jessie

RUN apt-get update\
 && apt-get install -y libssl1.0.0 ca-certificates\
 && ( dpkg -i /nginx_${NGINX_VERSION}_armhf.deb || apt-get -f install -y )\
 && ln -sf /dev/stdout /var/log/nginx/access.log\
 && ln -sf /dev/stderr /var/log/nginx/error.log\
 && apt-get clean && rm -rf /var/lib/apt/lists/*

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
