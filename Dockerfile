FROM debian:stable
MAINTAINER Piotr Król <piotr.krol@3mdeb.com>

# TBD: I'm not sure if this can replace dpkg-reconfigure
ENV DEBIAN_FRONTEND noninteractive

# Update the package repository
RUN apt-get update && \
    apt-get install -y locales

# Configure locales
# noninteractive installation using debconf-set-selections does not seem
# to work due to a bug in Debian glibc:
# https://bugs.launchpad.net/ubuntu/+source/glibc/+bug/1598326
# TBD: not sure if we still need that
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get install -y \
	bzip2 \
	libc6 \
	libkmod2 \
	libpci3 \
	libkmod2 \
	libpci-dev \
	libusb-dev \
	libusb-0.1.4 \
	libusb-1.0.0 \
	libusb-1.0.0-dev \
	libftdi1 \
	libftdi1-dev \
	zlib1g \
	zlib1g-dbg \
	zlib1g-dev \
	lib32z1 \
	lib32z1-dev \
	pciutils \
	acpica-tools \
	usbutils \
	cvs \
	wget \
	dmidecode \
	git \
	make \
	gcc \
	g++ \
	uuid-dev iasl \
	sudo \
	device-tree-compiler \
	libssl-dev \
	build-essential \
	nano \
	vim \
	&& \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/fwdump && cd /home/fwdump

WORKDIR /home/fwdump

RUN git clone https://review.coreboot.org/coreboot.git

RUN git clone https://github.com/flashrom/flashrom.git

RUN cd /home/fwdump/coreboot/util/superiotool && \
	make install

RUN cd /home/fwdump/coreboot/util/inteltool && \
	make install

RUN cd /home/fwdump/coreboot/util/ectool && \
	make install

RUN cd /home/fwdump/coreboot/util/msrtool && \
	./configure && \
	make install

RUN cd /home/fwdump/coreboot/util/nvramtool && \
	make install

RUN cd /home/fwdump/flashrom && \
	git checkout v1.1-rc1 && \
	make install 

RUN cd /home/fwdump

USER root
WORKDIR /home/fwdump
