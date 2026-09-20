FROM nginx:1.31.6-alpine

# WORKDIR is not required because an absolute destination path is used.

COPY . /usr/share/nginx/html

# EXPOSE 80 is inherited from the NGINX base image.

# No RUN instruction is required because the application is static and NGINX is already installed and configured by the base image.

# The NGINX base image already defines the command used to start NGINX, so a CMD instruction does not need to be redefined here.