FROM ubuntu
RUN apt update -y
RUN apt install nginx -y
EXPOSE 80
CMD ["nginx","-g","daemon off;"]
