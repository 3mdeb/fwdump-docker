# fwdump-docker

Dockerized utility for retrieving various firmware related information from computers.

Inspired by [coreboot Motherboard Porting Guide](https://www.coreboot.org/Motherboard_Porting_Guide)

## Pull docker image

```
docker pull 3mdeb/fwdump-docker
```

## Usage

```
docker run --rm --privileged -it -v $PWD:/home/fwdump fwdump-docker getlogs
```

The container inside must run as root, thus the Dockerfile uses the root user.
Otherwise some of the logs may not be obtained. To ensure the logs can be
accessed, the `getlogs.sh` script changes the ownership and file permissions to
user/group with UID/GID 1000.

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
