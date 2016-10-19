#!/bin/bash
# Create a recovery image for Linux using the System Rescue CD (www.system-rescue-cd.org)
#
# 30 September, 2016 by Orien "Nautical Hazard" Vandenbergh (orien.vandenbergh@lmco.com)
# Modest improvements by Justin "Sleepy Sandman"  Mercier (justin.mercier@ndpgroup.com)
#
# This script will create a system image of your Linux system that can be restored from the same
# recovery CD in the event of a failure.
#
# CAVEAT:  The target restore disk must be the same size or larger as the original
# CAVEAT:  The target restore disk must have no existing partitions
# CAVEAT:  Regardless of messages below, only NFSv3 (and not iSCSI) is currently supported
#
# USAGE:
#  To BACKUP:
#         0.  Disconnect any SAN connections or zone out non-boot LUNs
#         1.  Make sure you have a mountable backup system (i.e. NAS or secondary disk)
#         2.  Boot from the System Rescue CD media or image
#         3.  If using NFS or iSCSI, run 'net-setup' to configure your network
#         4.  Run this script and follow the prompts
#         5.  Reconnect any SAN connections or zone in needed non-boot LUNs
#         6.  Reboot
#
#  To RESTORE:
#         0.  Disconnect any SAN connections or zone out non-boot LUNs
#         1.  Make sure you have connectivity to the backup location (i.e. NAS or secondary disk)
#         2.  Boot from the System Rescure CD media or image
#         3.  If using NFS or iSCSI, run 'net-setup' to configure your network
#         5.  Mount the backup target on /mnt/backup (i.e. mount -t nfs 192.168.10.20:/backups /mnt/backup)
#         6.  Run the restore.sh file in the backup location to get the initial backup completed
#         7.  Consult the restore.sh file in the backup location for further instructions
#         8.  Reconnect any SAN connections or zone in needed non-boot LUNs
#         9.  Reboot
#

# Turn on extended glob magic
shopt -s extglob

CONFIG="./imager.cfg"

# If the user didn't provide some values, use the ones from the configuration file
function process_defaults() {
  PARANOIA_DELAY="${PARANOIA_DELAY:-$DEF_PARANOIA_DELAY}"
  NAS_Server="${NAS_Server:-$DEF_NAS_Server}"
  NAS_Proto="${NAS_Proto:-$DEF_NAS_Proto}"
  NAS_Volume="${NAS_Volume:-$DEF_NAS_Volume}"
  NAS_Mount="${NAS_Mount:-$DEF_NAS_Mount}"
  TARGET="${TARGET:-$DEF_Target}"

  DEST=$TARGET/$hostname
  FSARCHIVE=$DEST/fsarchive.fsa
}

# Retrieve a list of volumes exported by the specified NAS Server
function volume_list() {
  showmount --no-headers -e $NAS_Server | /usr/bin/awk '{print $1}'
}

# Test whether the specified volume is in the list of available volumes
function volume_available() {
  desired=$1
  echo `volume_list | /bin/egrep -c "^$desired\$"`
}

# Test whether the filesystem mounted at $NAS_Mount is the one we are going to try to mount
function already_mounted() {
  MATCH=`/bin/mount | grep " on $NAS_Mount "| /usr/bin/tail`
  PRECURSOR=`echo $MATCH | /usr/bin/awk '{print $1}'`
  echo $MATCH | grep -q "^$NAS_Server:$NAS_Volume on $NAS_Mount type $NAS_Proto"
}

# Attempt to mount the NAS filesystem, if all the conditions are in place to allow that.
function mount_nas_if_mountable() {
  [ -d "$NAS_Mount" ]   || mkdir -p $NAS_Mount || bad_syntax "NAS Mountpoint '-m' doesn't exist and can't be created"
  if mountpoint $NAS_Mount >/dev/null; then
    already_mounted || bad_syntax "A filesystem '$PRECURSOR' is already mounted on our NAS Mountpoint, cancelling"
  else
    mount -o nolock -t $NAS_Proto $NAS_Server:$NAS_Volume $NAS_Mount || die "Could not mount NAS!"
  fi
}

# Ensure all required arguments are provided and sane
function validate_parameters() {
  [ -z "$hostname" ]    && bad_syntax "No hostname '-h' specified"
  [ -z "$TARGET" ]      && bad_syntax "No target directory '-t' specified"
  [ -z "$NAS_Proto" ]   && bad_syntax "No NAS Protocol '-p' specified"
  [ -z "$NAS_Server" ]  && bad_syntax "No NAS Server '-s' specified"
  [ -z "$NAS_Volume" ]  && bad_syntax "No NAS Volume '-v' specified"
  [ -z "$NAS_Mount" ]   && bad_syntax "No NAS Mountpoint '-m' specified"

  # Ensure that the volume specified is one of the volumes exported to us
  [ `volume_available $NAS_Volume` -eq 1 ] || bad_volume
  mount_nas_if_mountable

  # At this point, the NAS filesystem is mounted, and everything should be ready for us
  [ ! -d "$TARGET" ]    && bad_syntax "Target directory specified with '-d' does not exist"
  # An existing backup will prevent execution, we don't want to stomp a backup
  [ -d "$DEST" ]        && bad_syntax "Backup directory '$DEST' already exists, please remove before running again"
}

# Load the settings from the configuration file
function load_configuration() {
  [ -f $CONFIG ] && source $CONFIG
}

# Display the countdown prior to making changes
function countdown() {
  # Generate the paranoia sequence
  function pseq() {
    seq `echo "$PARANOIA_DELAY - 1" | bc` -1 0
  }
  # Countdown to execution to allow the user to abort
  echo "We're about to do work, your warranty is about to expire..."
  echo "$PARANOIA_DELAY seconds... (Press CTRL-C to abort)"
  # (JFM) We should make this a while so it can be loop detected...
  # Maybe also multiply by 1000 so we can do progressional updates.

  for i in `pseq`; do
    sleep 1
    printf "\r$i seconds...\b"
  done
  echo -e "\rLudicrous Speed, GO!\b"
  echo ""
}

# A function to convert newlines to spaces (useful when invoking various syscalls herein)
function nltos() {
  sed -e ':a;N;$!ba;s/\n/ /g'
}

# Basically the help function that is called when arguments are not as expected
function display_syntax() {
  echo "Syntax: $0 -h <hostname> [ -t <target> ] [ -m <nas_mount> ]" # Our little secret [ -p <nas_proto> ]"
  echo "              [ -s <nas_server> ] [ -v <nas_volume> ] [ -d <delay> ]"
  echo ""
  echo "<hostname>   the name of the host you are creating the image for"
  echo "<target>     the directory into which the backup should be created"
  echo "             backups are placed into \$target/\$hostname/ (created as needed)"
  echo "             [$DEF_Target]"
  # Secret feature, don't tell anyone
  #echo "<nas_proto>  Protocol NAS server uses to share (nfs only) [$DEF_NAS_Proto]"
  echo "<nas_server> IP Address of the server sharing the backups filesystem [$DEF_NAS_Server]"
  echo "<nas_volume> Which volume from the server should we mount [$DEF_NAS_Volume]"
  echo "<nas_mount>  Which directory should the NAS storage be mounted on [$DEF_NAS_Mount]"
  echo "<delay>      how long to delay before engaging in destructive behavior"
  echo ""
  exit 2
}

# die function to echo a message and exit with generic error
function die() {
   echo "[FATAL] - $@ ...exiting."
   exit 1
}
function bad_syntax() {
  echo $@
  echo ""
  display_syntax
}
function bad_volume() {
  echo "Mountpoint selected is not available from the specified server"
  echo ""
  echo "Server: $NAS_Server"
  echo "Mount requested: $NAS_Mount"
  echo "Mounts available: " `volume_list`
  echo ""
  display_syntax
}

# Make sure we be root, or else exit with non-zero status (5)
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root, figure out a way to make that work..."
  #exit 5
fi

# Parse the provided command line arguments
while getopts "c:h:d:m:o:p:s:t:v:" opt; do
  case $opt in
    c)
      # Override the default filename for the configuration file
      CONFIG=$OPTARG
      ;;
    h)
      # Parse the hostname from the arguments since the rescue CD has no idea what the local system is
      hostname=$OPTARG
      ;;
    d)
      PARANOIA_DELAY=$OPTARG
      ;;
    m)
      NAS_Mount=$OPTARG
      ;;
    o)
      if [ "$OPTARG" = "〠" ]; then
        echo "Oh, you fancy now! The files are IN the computer!"
      fi
      ;;
    p)
      NAS_Proto=$OPTARG
      ;;
    s)
      NAS_Server=$OPTARG
      ;;
    t)
      # The NAS or secondary disk mount location, or wherever you would like
      # you backups to go, to which $hostname is appended.
      TARGET=$OPTARG
      ;;
    v)
      NAS_Volume=$OPTARG
      ;;
  esac
done
# Load the defailts from the configuration file
load_configuration
# Use the defaults if the user didn't specify an override
process_defaults
# Validate that the parameters we're about to use are semi-valid
validate_parameters

clear
echo "Welcome to the Icebergh Imager!"
echo "This utility will assist you in creating a rescue image for this system."
echo "Sadly, only backup to NAS over NFS is currently supported."
echo

# Inventory the local disk drives (WARNING: This may not be SAN safe!)
DISKGUESS=`(cd /dev/; ls [shv]d[a-z]* | grep -v '[0-9]') | nltos`
PARTGUESSRAW=`lsblk -nl | grep -v 'dm' | awk '$6 == "part" { print $1 }' | nltos`

# Inventory the LVM objects
PVS=`vgs -o +pv_name --noheadings | awk '{print $NF}' | nltos | sed -e 's/\/dev\///g'`
VGS=`vgs --noheadings | awk '{print $1}'`
LVS=`find /dev/mapper -type l | grep -v swap | nltos`

# Attempt to determine the boot device
PARTGUESSFS=$PARTGUESSRAW
for pv in $PVS; do
  PARTGUESSFS=${PARTGUESSFS//$pv?()}
done

# Make sure the filesystem is supported
for part in $PARTGUESSFS; do
  TYPE=""
  eval $(blkid /dev/$part | awk ' { print $3 } ')
  if [[ $FS == *"$TYPE"* ]] && [ -n "$TYPE" ]; then
    PARTGUESS="$PARTGUESS $part"
  fi
done

# I have no idea what this does.  Orien?
PARTGUESS=`echo $PARTGUESS | xargs`

# Prompt the user to specify which disks to back up, defaulting to the above detection logic.
printf "Which disk(s) would you like to backup? [$DISKGUESS]: "
read DISKS
echo

# Now that we have LVM covered, let's handle traditional filesystems such as /boot
echo "Now we need a list of \"raw\" partitions to back up.  The utility we're using"
echo "'fsarchiver' doesn't support backing up swap (for good reason).  If you"
echo "specify a swap partition here, the backup will fail.  In addition, we detect"
echo "the LVM partitions automatically, so only specify the non-lvm, non-swap"
echo "partitions.  Generally this is only the device for /boot (normally sda1)"
echo ""

# Prompt the user to override the auto-detected LVMs
printf "Which non-lvm partitions [$PARTGUESS]: "
read PARTS
echo

# If no disks are specified, exit with help
if [ -z "$DISKS" ]; then
  DISKS=$DISKGUESS
  if [ -z "$DISKS" ]; then
    echo "No source disks specified"
    display_syntax
  fi
fi

# If no partitions are specified, exit with help
if [ -z "$PARTS" ]; then
  PARTS=$PARTGUESS
  if [ -z "$PARTS" ]; then
    echo "No source partitions specified"
    display_syntax
  fi
fi

# We now have all the info we need (WTWTCH), so we perform the backup
echo "Performing a backup of the following to the directory '$DEST':"
echo "  Disks: $DISKS"
echo "  Partitions: $PARTS"
echo "  Volume Groups: $VGS"
echo "  Logical Volumes: $LVS"
echo ""
echo ""

# Display the cancellable countdown
countdown

echo "-- [$DEST] Creating directory"
mkdir $DEST
echo ""

# This seems like an exercise in futility that can be trimmed since
# we still need to reinstall grub
for disk in $DISKS; do
  echo "-- [$disk] Backing up MBR"
  dd if=/dev/$disk of=$DEST/$disk.mbr bs=1M count=2
  echo "-- [$disk] Backing up partition layout"
  sfdisk -d /dev/$disk > $DEST/$disk.part
done
echo ""

# Backup the LVM config to a flat file that we can reuse
for vg in $VGS; do
  echo "-- [$vg] Backing up LVM layout..."
  vgcfgbackup -f $DEST/$vg.vgcfg $vg
done
echo ""

# Dump the requested filesystem(s) to a fsarchiver filesystem archive (FSAi) file
echo "-- Starting fsarchiver, this will take some time..."
LABEL=`date +"$hostname-%Y%m%d%H%M%S-backup"`
FULLPARTS=`echo $PARTS | sed 's/[^ ]* */\/dev\/&/g'`
fsarchiver savefs -j4 -L "$LABEL" -o $FSARCHIVE $FULLPARTS $LVS

echo "-- Compiling restore data..."
echo "#!/bin/bash" > $DEST/restore.sh
chmod +x $DEST/restore.sh
echo "# There, now it's easy be careful out there" >> $DEST/restore.sh
echo "" >> $DEST/restore.sh
echo "DEST=$DEST" >> $DEST/restore.sh

for disk in $DISKS; do
  echo "dd if=\$DEST/$disk.mbr of=/dev/$disk bs=1M count=2" >> $DEST/restore.sh
  echo "sfdisk /dev/$disk < \$DEST/$disk.part" >> $DEST/restore.sh
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
  if [ -z $RESTOREFLAGS ]; then
    RESTOREFLAGS="id=$id,dest=$fs"
  else
    RESTOREFLAGS="$RESTOREFLAGS id=$id,dest=$fs"
  fi
  id=`echo "$id + 1" | bc`
done

echo "fsarchiver restfs \$DEST/fsarchive.fsa $RESTOREFLAGS" >> $DEST/restore.sh
echo "" >> $DEST/restore.sh
echo "echo Please run the rest of the commands in restore.sh manually." >> $DEST/restore.sh
echo "# Now for the hard part, I know you can do it!" >> $DEST/restore.sh
echo "#   mkdir /mnt/backup" >> $DEST/restore.sh
echo "#   mount /dev/mapper/<system-root> /mnt/backup" >> $DEST/restore.sh
echo "#   mount -o bind /dev /mnt/backup/dev" >> $DEST/restore.sh
echo "#   chroot /mnt/backup /bin/bash" >> $DEST/restore.sh
echo "#   mount <system-boot> /boot" >> $DEST/restore.sh
echo "#   grub-install <boot-device (/dev/sda)>" >> $DEST/restore.sh
echo "#   umount /mnt/backup/boot" >> $DEST/restore.sh
echo "#   exit" >> $DEST/restore.sh
echo "#   umount /mnt/backup/dev" >> $DEST/restore.sh
echo "#   umount /mnt/backup" >> $DEST/restore.sh
echo "#" >> $DEST/restore.sh
echo "# The good news is you're done.  umount the partition the backups live" >> $DEST/restore.sh
echo "# on, repeat the team mantra (WTWTCH), and reboot." >> $DEST/restore.sh

echo ""
echo ""
fsarchiver archinfo $FSARCHIVE | less
echo ""
echo "Does this look right to you?"
echo ""
ls -l $DEST
echo ""
echo "If it does, you're free to reboot, otherwise, fix it now!"

umount $NAS_Mount 2>/dev/null
exit 0
