#!/bin/bash
DEVICES=( "/dev/sdaa" "/dev/sdab" )
LOGFILE="./logfile"

# Now check mountpts and clean up partitions
for dev in "${DEVICES[@]}"; do
  echo "*************************"
  echo "Checking if ${dev} is in use, if yes abort"
  mount | grep ${dev}
  if [ $? == 0 ]; then
    echo "Device ${dev} is mounted - ABORTING Test!"
    exit 1
  fi

# Clears any existing partition table and create a new one
#   with a single partion that is the entire disk
    (echo o; echo n; echo p; echo 1; echo; echo; echo w) | \
      fdisk ${dev} >> $LOGFILE
# Now delete that partition
  for partition in $(parted -s ${dev} print|awk '/^ / {print $1}'); do
    echo "Removing parition: dev=${dev} - partition=${partition}"
    parted -s $dev rm ${partition} 
    if [ $? != 0 ]; then
      echo "$LINENO: Unable to remove ${partition} from ${dev}"
      exit 1
    fi
  done
  echo "Completed ${dev}"
done           # end FOR
