FROM debian:jessie
MAINTAINER BlankOn Developer <blankon-dev@googlegroups.com>

# Set Non Interactive Mode
ENV DEBIAN_FRONTEND noninteractive

# Set GPG
RUN gpg --keyserver pgpkeys.mit.edu --recv-key 91824AB09120A048 && gpg -a --export 91824AB09120A048 | apt-key add -

# Inject Repo
RUN echo "deb http://arsip.blankonlinux.or.id/blankon/ uluwatu main restricted extras extras-restricted" > /etc/apt/sources.list && \ 
    apt update && \
    apt dist-upgrade -y

# Install Blankon Desktop & Dev Requirement
RUN apt install blankon-desktop -y && \
    apt install gnome-common libglib2.0-dev gtk+-3.0-dev libunique-3.0-dev libwnck-3-dev libgee-dev libgnome-menu-3-dev valac libnotify-dev git -y

# Add Src
ADD . /manokwari

# Set Workdir
WORKDIR /manokwari

# Build Manokwari
RUN ./autogen.sh && \
    make && make install

# Run bash on start
CMD ["bash"]
