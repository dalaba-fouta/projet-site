FROM nginx
RUN rm -r /usr/share/nginx/html
COPY html /usr/share/nginx/
COPY nginx.conf /etc/nginx/nginx.conf