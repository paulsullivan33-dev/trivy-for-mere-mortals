FROM ubuntu:latest
RUN apt-get update && apt-get install -y curl sudo openssh-server
COPY . /app
WORKDIR /app
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
