#
# Dockerfile - Heka
#
# - Build
# docker build --rm -t heka /root/docker/production/heka
#
# - Run
# docker run -d --name="heka" -h "heka" -v /storage/logs:/logs heka
#
# - SSH
# ssh `docker inspect -f '{{ .NetworkSettings.IPAddress }}' heka`

FROM     ubuntu:14.04
MAINTAINER Yongbok Kim <ruo91@yongbok.net>

# Change the repository
RUN sed -i 's/archive.ubuntu.com/ftp.jaist.ac.jp/g' /etc/apt/sources.list

# Last Package Update & Install
RUN apt-get update && apt-get install -y curl openssh-server supervisor nano

# ENV
ENV SRC_DIR /opt
WORKDIR /opt

# Golang
ENV GOROOT /opt/go
ENV PATH $PATH:$GOROOT/bin
RUN curl -LO "https://storage.googleapis.com/golang/go1.4.linux-amd64.tar.gz" \
 && tar xzf go*.tar.gz && rm -f go*.tar.gz \
 && echo "# Golang" >> /etc/profile \
 && echo "export GOROOT=$GOROOT" >> /etc/profile \
 && echo 'export PATH=$PATH:$GOROOT/bin' >> /etc/profile

# Heka
ENV HEKA_HOME $SRC_DIR/heka
RUN apt-get install -y cmake git-core mercurial protobuf-compiler build-essential \
 && git clone https://github.com/mozilla-services/heka heka-source \
 && cd heka-source && ./build.sh \
 && mv build/heka $HEKA_HOME \
 && echo "# Heka" >> /etc/profile \
 && echo "export HEKA_HOME=$HEKA_HOME" >> /etc/profile \
 && echo 'export PATH=$PATH:$HEKA_HOME/bin' >> /etc/profile \
 && mkdir /etc/heka
ADD conf/heka.toml	/etc/heka/heka.toml

# Setting for supervisor
RUN mkdir -p /var/log/supervisor
ADD conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# SSH
RUN mkdir /var/run/sshd
RUN sed -i 's/without-password/yes/g' /etc/ssh/sshd_config
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config

# Set the root password for ssh
RUN echo 'root:heka' |chpasswd

# Port
EXPOSE 22 4352

# Daemon
CMD ["/usr/bin/supervisord"]
