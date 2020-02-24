#!/usr/bin/env bash

if [[ -z "$1" ]]; then
  echo -e "usage: sudo $0 <file.img>\n"
  exit
fi

if [[ $(whoami) != "root" ]]; then
  echo -e "error: this must be run as root: sudo $0 <file.img>"
  exit
fi


if [[ ! -e "$1" ]]; then
  echo -e "error: no such file\n"
  exit
fi

orig_img_size=$(stat --printf="%s" "$1")

part_info=$(parted -m "$1" unit B print)
echo -e "\n[+] partition info"
echo "----------------------------------------------"
echo -e "$part_info\n"

part_num=$(echo "$part_info" | grep ext4 | cut -d':' -f1)
part_start=$(echo "$part_info" | grep ext4 | cut -d':' -f2 | sed 's/B//g')
part_size=$(echo "$part_info" | grep ext4 | cut -d':' -f4 | sed 's/B//g')

echo -e "[+] setting up loopback\n"
loopback=$(losetup -f --show -o "$part_start" "$1")

echo "[+] checking loopback file system"
echo "----------------------------------------------"
e2fsck -f "$loopback"

echo -e "\n[+] determining minimum partition size"
min_size=$(resize2fs -P "$loopback" | cut -d':' -f2)

# next line is optional: comment out to remove 1% overhead to fs size
min_size=$(($min_size + $min_size / 100))

if [[ $part_size -lt $(($min_size * 4096 + 1048576)) ]]; then
  echo -e "\n[!] halt: image already as small as possible.\n"
  losetup -d "$loopback"
  exit
fi

echo -e "\n[+] resizing loopback fs (may take a while)"
echo "----------------------------------------------"
resize2fs -p "$loopback" "$min_size"
sleep 1

echo -e "[+] detaching loopback\n"
losetup -d "$loopback"

part_new_size=$(($min_size * 4096))
part_new_end=$(($part_start + $part_new_size))

echo -e "[+] adjusting partitions\n"
parted "$1" rm "$part_num"
parted "$1" unit B mkpart primary $part_start $part_new_end

free_space_start=$(parted -m "$1" unit B print free | tail -1 | cut -d':' -f2 | sed 's/B//g')

echo -e "[+] truncating image\n"
truncate -s $free_space_start "$1"

new_img_size=$(stat --printf="%s" "$1")
bytes_saved=$(($orig_img_size - $new_img_size))
echo -e "DONE: reduced "$1" by $(($bytes_saved/1024))KiB ($((bytes_saved/1024/1024))MB)\n"