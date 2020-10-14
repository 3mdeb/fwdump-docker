# fwdump-docker

[![Build Status](https://travis-ci.com/3mdeb/fwdump-docker.svg?branch=master)](https://travis-ci.com/3mdeb/fwdump-docker)

Dockerized utility for retrieving various firmware related information from computers.

Inspired by [coreboot Motherboard Porting Guide](https://www.coreboot.org/Motherboard_Porting_Guide)

The container has been designed to avoid installing many dependencies, build
tools and other packages on the system required to dump logs for firmware.
`fwdump-docker` will ease the dumping process due to the only requirement which
is the docker itself.

## Pull docker image

```
docker pull 3mdeb/fwdump-docker
```

## Usage

```
docker run --rm --privileged -it -v $PWD:/home/fwdump 3mdeb/fwdump-docker getlogs
```

> It may be required to load msr kernel module before executing docker:
> `modprobe msr`.

The container inside must run as root, thus the Dockerfile uses the root user.
Otherwise some of the logs may not be obtained. To ensure the logs can be
accessed, the `getlogs.sh` script changes the ownership and file permissions to
user/group with UID/GID 1000.

The result is placed in the `$PWD` directory packed into a tarball named:
`<system-manufacturer>_<system-product-name>_<bios-version>.tar.gz`.

## Build Docker image

```
./build.sh
```

## Release Docker image

Refer to the [docker-release-manager](https://github.com/3mdeb/docker-release-manager/blob/master/README.md)

## Troubleshooting

If similar message appears:

- in `flashrom.err.log` :

```
ERROR: Could not get I/O privileges (Operation not permitted).
You need to be root.
Error: Programmer initialization failed.
```

- in `superiotool.err.log`

```
iopl: Operation not permitted
```

You may need to add `iomem=relaxed` parameter to linux kernel command line.
