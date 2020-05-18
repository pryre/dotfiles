#!/bin/sh

NFSPATH=$1

TMPDIR=/tmp/pryre
PROGDIR=/nfsZeroconf
NFSDIR=$(echo "$NFSPATH" | tr [./] '_')
if [ "$XDG_RUNTIME_DIR" ]
then
	TMPDIR=$XDG_RUNTIME_DIR
fi

# Strip Avahi port if it exists


# Mount directory
mkdir -p "${TMPDIR}${PROGDIR}/${NFSDIR}"
mount sudo mount -t nfs 10.10.0.10:/backups /var/backups
