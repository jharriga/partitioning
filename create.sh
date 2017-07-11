# create.sh
#-----------------------
# AFTER RUNNING lsblk output resembles:
# nvme0n1               259:0    0 372.6G  0 disk 
# ├─nvme0n1p1           259:1    0    12G  0 part 
# ├─nvme0n1p2           259:2    0    12G  0 part 
# └─nvme0n1p3           259:3    0    12G  0 part 
# 
# sde                     8:64   0   1.8T  0 disk 
# sdf                     8:80   0   1.8T  0 disk 
# sdg                     8:96   0   1.8T  0 disk 
#
# Based on: https://superuser.com/questions/332252/
#
###############################################################
fastDEV="nvme0n1"
fastTARGET="/dev/${fastDEV}"

#----------------------------------
# First - do the NVME
echo "Partitioning $fastTARGET"
echo "BEGIN: Listing matching device names"
# List the available block devices
lsblk | grep $fastDEV

# Create the partitions programatically (rather than manually)
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "default" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${fastTARGET}
  o       # clear the in memory partition table
  n       # new partition
  p       # primary partition
  1       # partition number 1
          # default, start at beginning of disk 
  +12G    # 10 GB partition
  n       # new partition
  p       # primary partition
  2       # partition number 2
          # default, start immediately after preceding partition
  +12G    # 10 GB partition
  n       # new partition
  p       # primary partition
  3       # partition number 3
          # default, start immediately after preceeding partition
  +12G    # 10 GB partition
  p       # print the in-memory partition table
  w       # write the partition table
  q       # and we're done
EOF

echo "COMPLETED partitioning $fastDEV"
lsblk | grep $fastDEV

#----------------------------------
# Second - do the HDDs

#for hdd in "${slowDEV_arr[@]}"; do
#  echo "Partitioning $hdd"
#  echo "BEGIN: Listing matching device names"
#  # List the available block devices
#  lsblk | grep $hdd
#  sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF2 | fdisk ${hdd}
#    o       # clear the in memory partition table
#    n       # new partition
#    p       # primary partition
#    1       # partition number 1
#            # default, start at beginning of disk 
#    +120G   # 100 GB partition
#    p       # print the in-memory partition table
#    w       # write the partition table
#    q       # and we're done
#EOF2
#  echo "COMPLETED partitioning $hdd"
#done

echo "COMPLETED partitioning all devices"

