FROM nginx:1.25-alpine

WORKDIR /usr/share/nginx/html
RUN rm -rf /usr/share/nginx/html/*

COPY index.html . 
COPY meta/ meta/
COPY js/ js/
COPY style/ style/
COPY favicon.ico .

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]