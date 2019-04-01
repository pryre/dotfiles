#!/bin/sh

if [ $# -eq 1 ]
then
	IMAGE=$1
	I_INFO=$(fdisk -o end -l $IMAGE)
	S_INFO=$(echo "$I_INFO" | grep -F 'Units: ')
	S_SIZE=$(echo "$S_INFO" | cut -d'=' -f2 | sed -e 's/^[[:space:]]*//' | cut -d' ' -f1)

	E_INFO=$(echo "$I_INFO" | sed -n '/     End/,$p' | tail -n +2 | sed -e 's/^[[:space:]]*//')

	#echo "$E_INFO"

	LAST_SEC=$(echo "$E_INFO" | sort -rn | head -n 1)

	echo "Sector size: $S_SIZE"
	echo "End Sector: $LAST_SEC"

	read -p "Proceed with truncation? " -n 1 -r
	echo ""
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		truncate --size=$[(${LAST_SEC}+1)*${S_SIZE}] ${IMAGE}
	fi
else
	echo "Usage: truncate_image.sh /image/name.img"
fi