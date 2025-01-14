#!/bin/bash

set -x

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

hid_xpadneo=$(modinfo -n hid-xpadneo 2> /dev/null)
hid=$(modinfo -n hid 2> /dev/null)
bluetooth=$(modinfo -n bluetooth 2> /dev/null)

extramodules="/lib/modules/"$(uname -r)"/extramodules/"


sudo [ ! -d "$extramodules"_bak ] && sudo mkdir --parents $extramodules

# install xpadneo

if [ "$hid_xpadneo" == "" ]
then
  echo "** install xpadneo"
  sudo cp -f ./hid-xpadneo.ko "$extramodules"
else
  echo "** replace xpadneo"
  sudo [ ! -f "$hid_xpadneo"_bak ] && sudo mv "$hid_xpadneo" "$hid_xpadneo"_bak
  sudo cp -f ./hid-xpadneo.ko $(dirname "$hid_xpadneo")
fi

# install hid

if [ "$hid" == "" ]
then
  echo "** install hid"
  sudo cp -f ./hid.ko "$extramodules"
else
  echo "** replace hid"
  sudo [ ! -f "$hid"_bak ] && sudo mv "$hid" "$hid"_bak
  sudo cp -f ./hid.ko $(dirname "$hid")
fi

# install bluetooth

if [ "$bluetooth" == "" ]
then
  echo "** install bluetooth"
  sudo cp -f ./bluetooth.ko "$extramodules"
else
  echo "** replace bluetooth"
  sudo [ ! -f "$bluetooth"_bak ] && sudo mv "$bluetooth" "$bluetooth"_bak
  sudo cp -f ./bluetooth.ko $(dirname "$bluetooth")
fi


sudo depmod

sudo modprobe hid-xpadneo
sudo modprobe hid
sudo modprobe bluetooth


if [[ $(crc32 $hid) != $(crc32 ./hid.ko) \
   || $(crc32 $bluetooth) != $(crc32 ./bluetooth.ko) \
   || $(crc32 $hid_xpadneo) != $(crc32 ./hid-xpadneo.ko) ]]
then
  echo something went wrong, files checksums are not correct
  exit 1
else 
  echo "* installed/replaced successfully"
fi;
