#!/bin/bash
# A script to dump info about the touchpad

uid=$(id -u)
if [ $uid -ne 0 ]; then
	echo "This script must be run as root!"
	exit
fi

echo "Kernel log:"
dmesg

echo "running i2cdetect (quick write mode)"
i2cdetect -y -q 1

echo "running i2cdetect (receive byte mode)"
i2cdetect -y -r 1

dmesg | grep hid-generic | grep "I2C HID" > /dev/null
if [ $? -ne 0 ]; then
	echo "No I2C touchpads detected. Exiting"
	exit
fi

devpath=$(dmesg | grep hid-generic | grep "I2C HID" | awk '{print $4}' | cut -d ':' -f 1-3)

echo "Installing dependencies"
apt-get update
apt-get install -y i2c-tools acpi-call-dkms

echo "Loading module acpi_call"
modprobe acpi_call

devname=$(dmesg | grep hid-generic | awk 'NF>1{print $NF}')
hid=$(cat /sys/bus/i2c/devices/$devname/firmware_node/hid)
path=$(cat /sys/bus/i2c/devices/$devname/firmware_node/path)

echo "$path._DSM bF7F6DF3C67425545AD05B30A3D8938DE 1 1" > /proc/acpi/call
descriptor_offset=$(cat /proc/acpi/call | tr -d '\0' | cut -d 'c' -f 1)

i2c_row=$(i2cdetect -y -r 1 | grep UU)
i2c_col=0
for x in $i2c_row
do
	if [ $x = 'UU' ]; then
		break;
	fi
	i2c_col=$(($i2c_col + 1))
done

i2c_addr=$(echo $i2c_row | cut -d ":" -f 1)
i2c_col=$(printf '%x\n' $(($i2c_col - 1)))
i2c_addr=$(printf '%x\n' $((16#$i2c_addr + 16#$i2c_col)))

echo Found touchpad at $path:
echo
echo "HID:                $hid"
echo "I2C address:        0x$i2c_addr"
echo "Descriptor address: $descriptor_offset"
echo
echo "Unloading module acpi_call"
rmmod acpi_call
