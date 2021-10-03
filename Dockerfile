FROM jetbrains/teamcity-minimal-agent

LABEL maintainer="cmtedouglas@hotmail.com"
LABEL description="custom teamcity agent image for compiling rust and go jobs."

ENV LANG C.UTF-8
ENV DEBIAN-FRONTEND noninteractive
USER root
RUN set -x && \
	rm -rf /var/lib/apt/lists/*

# Install basic tools
RUN set -x && \
	apt-get update && \
	apt-get install apt-transport-https ca-certificates -y && \
	apt-get install build-essential -y && \
	apt-get install flex bison bc dc wget curl git -y

# Install go toolkit
RUN set -x && \
	cd /tmp && \
	wget https://golang.org/dl/go1.16.3.linux-amd64.tar.gz 
RUN set -ex && \
	cd /tmp && \
	tar -C /usr/local -zxf go1.16.3.linux-amd64.tar.gz && \
	update-alternatives --install "/usr/bin/go" "go" "/usr/local/go/bin/go" 0 && \
	update-alternatives --set go /usr/local/go/bin/go && \
	rm -rf /tmp/*

USER buildagent
RUN set -ex && \
	mkdir ~/.go 

# Install rust toolkit
RUN set -ex && \
	cd ~ && \
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rust.sh && \
	chmod +x rust.sh && \
	./rust.sh -y && \
	. ~/.cargo/env

ENV GOROOT /usr/local/go
ENV GOPATH /home/buildagent/go
ENV CARGO_HOME /home/buildagent/.cargo

ENV PATH /opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$GOROOT/bin:$GOPATH/bin:$CARGO_HOME/bin


CMD ["/run-services.sh"]
