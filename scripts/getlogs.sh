#!/bin/bash

if [ -d logs ]; then
	rm -rf logs
fi

mkdir logs

lspci -nnvvvxxxx > logs/lspci.log 2> logs/lspci.err.log
lsusb -vvv > logs/lsusb.log 2> logs/lsusb.err.log
superiotool -deV > logs/superiotool.log 2> logs/superiotool.err.log
ectool -i > logs/ectool.log 2> logs/ectool.err.log
msrtool > logs/msrtool.log 2> logs/msrtool.err.log
dmidecode > logs/dmidecode.log 2> logs/dmidecode.err.log
biosdecode > logs/biosdecode.log 2> logs/biosdecode.err.log
nvramtool -x > logs/nvramtool.log 2> logs/nvramtool.err.log
dmesg > logs/dmesg.log 2> logs/dmesg.err.log
acpidump > logs/acpidump.log 2> logs/acpidump.err.log
for x in /sys/class/sound/card0/hw*; do cat "$x/init_pin_configs" > logs/pin_"$(basename "$x")"; done
for x in /proc/asound/card0/codec#*; do cat "$x" > logs/"$(basename "$x")"; done
cat /proc/cpuinfo > logs/cpuinfo.log 2> logs/cpuinfo.err.log
cat /proc/ioports > logs/ioports.log 2> logs/ioports.err.log
cat /sys/class/input/input*/id/bustype > logs/input_bustypes.log
flashrom -V -p internal:laptop=force_I_want_a_brick -r logs/rom.bin > logs/flashrom_read.log 2> logs/flashrom_read.err.log

mkdir -p logs/acpi && cd logs/acpi
acpixtract -a ../acpidump.log
iasl -d *.dat
cd ../..

chown -R 1000:1000 logs/ && chmod 755 logs
tar -zcvf fwlogs.tar.gz logs/* && chmod 755 fwlogs.tar.gz && chown 1000:1000 fwlogs.tar.gz

