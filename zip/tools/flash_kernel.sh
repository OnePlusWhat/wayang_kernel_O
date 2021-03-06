#!/sbin/sh
 #
 # Copyright © 2017-2018, Umang Leekha "umang96" <umangleekha3@gmail.com> , Viky Dwi Santoso "vicatz" <vickky@programmer.net> 
 #
 # Live ramdisk patching script
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it
 #
zim=/tmp/Image.gz-dtb
#cmd=$cmd""
cp -f /tmp/cpio /sbin/cpio
cd /tmp/
/sbin/busybox dd if=/dev/block/bootdevice/by-name/boot of=./boot.img
./unpackbootimg -i /tmp/boot.img
mkdir /tmp/ramdisk
cp /tmp/boot.img-ramdisk.gz /tmp/ramdisk/
cd /tmp/ramdisk/
gunzip -c /tmp/ramdisk/boot.img-ramdisk.gz | /tmp/cpio -i
rm /tmp/ramdisk/boot.img-ramdisk.gz
rm /tmp/boot.img-ramdisk.gz
cp /tmp/init.wayang.rc /tmp/ramdisk/

# REMOVE SPECTRUM SCRIPT IF ANY
if [ -f /tmp/ramdisk/init.spectrum.rc ]; then
rm /tmp/ramdisk/init.spectrum.rc
fi
if [ -f /tmp/ramdisk/init.spectrum.sh ]; then
rm /tmp/ramdisk/init.spectrum.sh
fi

# Clear Unsupported stuff in ramdisk
rm /tmp/ramdisk/extracted/init.fk.rc
rm /tmp/ramdisk/extracted/init.performance_profiles.rc
rm /tmp/ramdisk/extracted/init.special_power.sh
rm /tmp/ramdisk/extracted/init.supolicy.sh
rm /tmp/ramdisk/extracted/init.kud.rc
rm /tmp/ramdisk/extracted/init.inferno.rc
rm /tmp/ramdisk/extracted/init.chewy.rc
rm /tmp/ramdisk/extracted/init.jembut.rc
rm /tmp/ramdisk/extracted/init.jembut.rc
rm /tmp/ramdisk/extracted/init.jembut.rc
rm /tmp/ramdisk/extracted/init.jembut.rc
# Clear Unsupported stuff END

# Treble and Nontreble OS detected
if ([ "`grep "ro.treble.enabled=true" /system/build.prop`" ]); then
dtb=/tmp/msm8953-qrd-sku3-mido-treble.dtb;
else
dtb=/tmp/msm8953-qrd-sku3-mido-nontreble.dtb;
fi;

# Suck kernel
cat /tmp/Image.gz $dtb > /tmp/Image.gz-dtb
cmd="$(cat /tmp/boot.img-cmdline)"

# COMPATIBILITY FIXES END
chmod 0755 /tmp/ramdisk/init.wayang.rc
if [ $(grep -c "import /init.wayang.rc" /tmp/ramdisk/init.rc) == 0 ]; then
   sed -i "/import \/init\.\environ\.rc/aimport /init.wayang.rc" /tmp/ramdisk/init.rc
fi
find . | cpio -o -H newc | gzip > /tmp/boot.img-ramdisk.gz
rm -r /tmp/ramdisk
cd /tmp/
./mkbootimg --kernel $zim --ramdisk /tmp/boot.img-ramdisk.gz --cmdline "$cmd" --base 0x80000000 --pagesize 2048 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 -o /tmp/newboot.img
/sbin/busybox dd if=/tmp/newboot.img of=/dev/block/bootdevice/by-name/boot
