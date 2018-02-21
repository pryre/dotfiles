#!/bin/bash
read -p "Username: " VPN_USER
read -s -p "Password: " VPN_PASS
echo

echo "Mounting CyPhy file share"
sudo mount -t cifs //hpc-fs.qut.edu.au/work/cyphy /mnt/nfs/cyphy -o user=$VPN_USER,dom=QUTAD,password=$VPN_PASS

read -p "Press any key to unmount..."

echo "Unmounting CyPhy file share"
sudo umount /mnt/nfs/cyphy

