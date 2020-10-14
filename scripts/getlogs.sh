#!/bin/bash

if [ -d logs ]; then
	rm -rf logs
fi

mkdir logs

echo "Dumping PCI configuration space and topology..."
lspci -nnvvvxxxx > logs/lspci.log 2> logs/lspci.err.log
echo "Dumping USB devices and topology..."
lsusb -vvv > logs/lsusb.log 2> logs/lsusb.err.log
echo "Dumping Super I/O configuration..."
superiotool -deV > logs/superiotool.log 2> logs/superiotool.err.log
echo "Dumping Embedded Controller configuration (this may take a while if EC is not present)..."
ectool -ip > logs/ectool.log 2> logs/ectool.err.log
echo "Dumping MSRs..."
msrtool > logs/msrtool.log 2> logs/msrtool.err.log
echo "Dumping SMBIOS tables..."
dmidecode > logs/dmidecode.log 2> logs/dmidecode.err.log
echo "Decoding BIOS information..."
biosdecode > logs/biosdecode.log 2> logs/biosdecode.err.log
echo "Extracting CMOS NVRAM..."
nvramtool -x > logs/nvramtool.log 2> logs/nvramtool.err.log
echo "Dumping Intel configuration registers..."
inteltool -a > logs/inteltool.log 2> logs/inteltool.err.log
echo "Dumping kernel dmesg..."
dmesg > logs/dmesg.log 2> logs/dmesg.err.log
echo "Dumping dumpign ACPI tables..."
acpidump > logs/acpidump.log 2> logs/acpidump.err.log
echo "Dumping Audio devices configuration..."
for x in /sys/class/sound/card0/hw*; do cat "$x/init_pin_configs" > logs/pin_"$(basename "$x")"; done
for x in /proc/asound/card0/codec#*; do cat "$x" > logs/"$(basename "$x")"; done
echo "Dumping CPU info..."
cat /proc/cpuinfo > logs/cpuinfo.log 2> logs/cpuinfo.err.log
echo "Dumping I/O ports..."
cat /proc/ioports > logs/ioports.log 2> logs/ioports.err.log
echo "Dumping input bus types..."
cat /sys/class/input/input*/id/bustype > logs/input_bustypes.log
echo "Tryign to read firmware image with flashrom..."
flashrom -V -p internal:laptop=force_I_want_a_brick -r logs/rom.bin > logs/flashrom_read.log 2> logs/flashrom_read.err.log

echo "Decompiling ACPI tables..."
mkdir -p logs/acpi && cd logs/acpi
acpixtract -a ../acpidump.log
iasl -d *.dat
cd ../..

chown -R 1000:1000 logs/ && chmod 755 logs
tar -zcvf fwlogs.tar.gz logs/* && chmod 755 fwlogs.tar.gz && chown 1000:1000 fwlogs.tar.gz

