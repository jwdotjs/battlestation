#!/bin/bash
#
# Translate a MAC address fetched from VirtualBox into a IP address


if [  $# -lt 1 ]; then
  echo -e "\nUsage:\n$0 [virtual machine] \n"
  exit 1
fi

origMessage=$(VBoxManage guestproperty get $1 /VirtualBox/GuestInfo/Net/0/V4/IP)

echo $origMessage | sed 's/Value: //'
