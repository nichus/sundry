#!/bin/bash

shopt -s extglob

PARANOIA_DELAY=30
PARANOIA_SEQ=`echo "$PARANOIA_DELAY - 1" | bc`
HOSTNAME="$1"
TARGET="$2"
DEST=$TARGET/$HOSTNAME
FS="ext2 ext3 ext4 reiserfs reiser4 xfs jfs btrfs ntfs"

nltos() {
  sed -e ':a;N;$!ba;s/\n/ /g'
}
display_syntax() {
  echo "Syntax: create_diskimage.sh <hostname> <target>"
  echo ""
  echo "<hostname> is the name of the host you are creating the image for"
  echo "<target> is the directory into which the backup should be created"
  echo "         backups are placed into \$target/\$hostname/ (created as needed)"
  echo ""
  exit 2
}

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root, figure out a way to make that work..."
  exit 5
fi

if [ -z "$HOSTNAME" ]; then
  echo "No hostname specified"
  display_syntax
fi
if [ -z "$TARGET" ]; then
  echo "No target directory specified"
  display_syntax
fi
if [ ! -d $TARGET ]; then
  echo "Target directory doesn't exist"
  display_syntax
fi
if [ -d $DEST ]; then
  echo "Backup directory '$DEST' already exists, please remove before running again..."
  exit -1
fi

DISKGUESS=`(cd /dev/; ls [shv]d[a-z]* | grep -v '[0-9]') | nltos`
PARTGUESSRAW=`lsblk -nl | grep -v 'dm' | awk '$6 == "part" { print $1 }' | nltos`

PVS=`vgs -o +pv_name --noheadings | awk '{print $NF}' | nltos | sed -e 's/\/dev\///g'`
VGS=`vgs --noheadings | awk '{print $1}'`
LVS=`find /dev/mapper -type l | grep -v swap | nltos`

PARTGUESSFS=$PARTGUESSRAW
for pv in $PVS; do
  PARTGUESSFS=${PARTGUESSFS//$pv?()}
done

for part in $PARTGUESSFS; do
  TYPE=""
  eval $(blkid /dev/$part | awk ' { print $3 } ')
  if [[ $FS == *"$TYPE"* ]] && [ -n "$TYPE" ]; then
    PARTGUESS="$PARTGUESS $part"
  fi
done

PARTGUESS=`echo $PARTGUESS | xargs`

printf "Which disks [$DISKGUESS]: "
read DISKS
echo

echo "Now we need a list of \"raw\" partitions to back up.  The utility we're using"
echo "'fsarchiver' doesn't support backing up swap (for good reason).  If you"
echo "specify a swap partition here, the backup will fail.  In addition, we detect"
echo "the LVM partitions automatically, so only specify the non-lvm, non-swap"
echo "partitions.  Generally this is only the device for /boot (normally sda1)"
echo ""
printf "Which non-lvm partitions [$PARTGUESS]: "
read PARTS
echo

if [ -z "$DISKS" ]; then
  DISKS=$DISKGUESS
  if [ -z "$DISKS" ]; then
    echo "No source disks specified"
    display_syntax
  fi
fi
if [ -z "$PARTS" ]; then
  PARTS=$PARTGUESS
  if [ -z "$PARTS" ]; then
    echo "No source partitions specified"
    display_syntax
  fi
fi

echo "Performing a backup of the following to the directory '$DEST':"
echo "  Disks: $DISKS"
echo "  Partitions: $PARTS"
echo "  Volume Groups: $VGS"
echo "  Logical Volumes: $LVS"
echo ""
echo ""
echo "We're about to do work, your warranty is about to expire..."
printf "$PARANOIA_DELAY seconds..."
for i in `seq $PARANOIA_SEQ -1 0`; do
  sleep 1
  printf "\r$i seconds... \b"
done
echo -e "\rexpired!        "
echo ""

echo "-- [$DEST] Creating directory"
mkdir $DEST
echo ""

for disk in $DISKS; do
  echo "-- [$disk] Backing up MBR"
  dd if=/dev/$disk of=$DEST/$disk.mbr bs=512 count=1
  echo "-- [$disk] Backing up partition layout"
  sfdisk -d /dev/$disk > $DEST/$disk.part
done
echo ""

for vg in $VGS; do
  echo "-- [$vg] Backing up LVM layout..."
  vgcfgbackup -f $DEST/$vg.vgcfg $vg
done
echo ""

echo "-- Starting fsarchiver, this will take some time..."
LABEL=`date +"$HOSTNAME-%Y%m%d%H%M%S-backup"`
FULLPARTS=`echo $PARTS | sed 's/[^ ]* */\/dev\/&/g'`
fsarchiver savefs -j4 -L "$LABEL" -o $DEST/fsarchive.fsa $FULLPARTS $LVS

echo "-- Recording data to make a restore easier..."
echo "exit # Ha, you thought i was gonna make this easy?" > $DEST/restore.sh
echo "DEST=$DEST" >> $DEST/restore.sh

for disk in $DISKS; do
  echo "sfdisk /dev/$disk < \$DEST/$disk.part" >> $DEST/restore.sh
  echo "dd if=\$DEST/$disk.mbr of=/dev/$disk.mbr bs=512 count=1" >> $DEST/restore.sh
done

for vg in $VGS; do
  pv=`vgs -o +pv_name --noheadings $vg | awk '{print $NF}'`
  uuid=`pvs -o +uuid --noheadings $pv | awk '{print $NF}'`
  echo "pvcreate --uuid $uuid --restorefile \$DEST/$vg.vgcfg $pv" >> $DEST/restore.sh
  echo "vgcfgrestore -f \$DEST/$vg.vgcfg $vg" >> $DEST/restore.sh
  echo "vgchange -a y $vg" >> $DEST/restore.sh
done

id=0
RESTOREFLAGS=""
for fs in $FULLPARTS $LVS; do
  RESTOREFLAGS="$RESTOREFLAGS id=$id,dest=$fs"
  id=`echo "$id + 1" | bc`
done

echo "fsarchiver restfs $RESTOREFLAGS" >> $DEST/restore.sh
echo "" >> $DEST/restore.sh
echo "# Now for the hard part, I know you can do it!" >> $DEST/restore.sh
echo "#   mount /dev/mapper/<system-root> /mnt/backup" >> $DEST/restore.sh
echo "#   mount -o bind /dev /mnt/backup/dev" >> $DEST/restore.sh
echo "#   mount <system-boot> /mnt/backup/boot" >> $DEST/restore.sh
echo "#   chroot /mnt/backup /bin/bash" >> $DEST/restore.sh
echo "#   grub-install <boot-device (/dev/sda)>" >> $DEST/restore.sh
echo "#   exit" >> $DEST/restore.sh
echo "#   umount /mnt/backup/boot" >> $DEST/restore.sh
echo "#   umount /mnt/backup/dev" >> $DEST/restore.sh
echo "#   umount /mnt/backup" >> $DEST/restore.sh
echo "#" >> $DEST/restore.sh
echo "# The good news is you're done.  umount the partition the backups live" >> $DEST/restore.sh
echo "# on, repeat the team mantra, and reboot" >> $DEST/restore.sh

echo ""
echo ""
echo "All done, to view contents, run: 'fsarchiver archinfo $DEST/fsarchive.fsa'"
exit 0
