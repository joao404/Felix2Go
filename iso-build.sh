#!/bin/bash

# This file is part of Felix2Go.
#
# Felix2Go is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Felix2Go is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Felix2Go.  If not, see <http://www.gnu.org/licenses/>.


APPS_DIR=$PWD/apps
OUT_DIR=$PWD/output/
LOOPDIR=$OUT_DIR/__loopdir__
CDDIR=$OUT_DIR/__cd__
IRDIR=$OUT_DIR/__irmod__
ISOVERSION=10.7.0
ISOFILE=debian-${ISOVERSION}-amd64-netinst.iso
ISO=$PWD/iso/${ISOFILE}
OUTPUTISO=$PWD/output/Felix2go.iso
PRESEED_CFG=$PWD/iso/felix-preseed.cfg
NEW_PRESEED_CFG=$PWD/iso/new-preseed.cfg
TMPF=/tmp/tmp_preseed.txt
MAKE_SELF=$PWD/makeself/makeself.sh
echo "Automated ISO generator"

function getDebianOs(){
cd $PWD/iso
echo ${ISOVERSION}
echo ${ISOFILE}
if [ ! -e ${ISOFILE} ]; then
wget http://cdimage.debian.org/debian-cd/${ISOVERSION}/amd64/iso-cd/${ISOFILE}
else
echo "File already exists"
fi
}

function createExeApps() {
cd $APPS_DIR
for i in $(ls -d *); 
do 
    echo "Compressing... " ${i}; 
    $MAKE_SELF ${i} $OUT_DIR/${i}.run "${i}" ./postinstall.sh #>/dev/null 2>&1
done
} 



function generateISO() {
echo "Generating ISO ... "
genisoimage -o $OUTPUTISO  -r -J -no-emul-boot -boot-load-size 4  -boot-info-table -b isolinux/isolinux.bin -c isolinux/boot.cat $CDDIR >/dev/null 2>&1
}

function copyApps() {

echo "Copying Apps"
mkdir $CDDIR/felix
cp $OUT_DIR/*.run $CDDIR/felix  
cd $CDDIR
md5sum `find -follow -type f` > md5sum.txt
cd ..
echo "ENd Copying Apps"
}


function changeTimeout() {
cd $CDDIR/isolinux
sed 's/timeout 0/timeout 5/' isolinux.cfg > tmp
mv tmp isolinux.cfg
}
function cleanup() {
echo "Cleaning up output directory"
cd $OUT_DIR
rm -rf $CDDIR $LOOPDIR *.run
}
function copySeed() {
echo "Copying preseed file"
cp $PRESEED_CFG  $NEW_PRESEED_CFG

cd $APPS_DIR
printf "d-i preseed/late_command string cp ">$TMPF
for i in $(ls -d *);
do
    printf "/cdrom/felix/${i}.run  ">>$TMPF
done
printf " /target/root/; ">>$TMPF


printf "chroot /target chmod +x ">>$TMPF
for i in $(ls -d *);
do
    printf "/root/${i}.run  ">>$TMPF
done
printf ";">>$TMPF
for i in $(ls -d *);
do
    printf "chroot /target /root/${i}.run;">>$TMPF
done
cat $TMPF>>$NEW_PRESEED_CFG

}

function hackInitrd() {
[ -e $IRDIR ] && rm -rf $IRDIR
mkdir $IRDIR
cd $IRDIR
gzip -d < $CDDIR/install.amd/initrd.gz |cpio --extract --verbose --make-directories --no-absolute-filenames 
#gzip -d < $CDDIR/install.amd/initrd.gz |cpio --extract --make-directories --no-absolute-filenames >/dev/null 2>&1
cp $NEW_PRESEED_CFG  preseed.cfg 
find . | cpio -H newc --create --verbose | gzip -9 >initrd.gz 
#find . | cpio -H newc --create | gzip -9 >initrd.gz >/dev/null 2>&1
cp initrd.gz $CDDIR/install.amd/
cd ..
rm -rf $IRDIR

}

function hackInitrdGtk() {
[ -e $IRDIR ] && rm -rf $IRDIR
mkdir $IRDIR
cd $IRDIR
gzip -d < $CDDIR/install.amd/gtk/initrd.gz |cpio --extract --verbose --make-directories --no-absolute-filenames 
#gzip -d < $CDDIR/install.amd/initrd.gz |cpio --extract --make-directories --no-absolute-filenames >/dev/null 2>&1
cp $NEW_PRESEED_CFG  preseed.cfg 
find . | cpio -H newc --create --verbose | gzip -9 >initrd.gz 
#find . | cpio -H newc --create | gzip -9 >initrd.gz >/dev/null 2>&1
cp initrd.gz $CDDIR/install.amd/gtk/
cd ..
rm -rf $IRDIR

}

function copyImage() {

echo $CDDIR
[ -e $LOOPDIR ] && rm -rf $LOOPDIR
mkdir $LOOPDIR
[ -e $CDDIR ] && rm -rf $CDDIR
mkdir $CDDIR
echo "Mounting iso...."
mount -o loop $ISO $LOOPDIR
rsync -a -H --exclude=TRANS.TBL $LOOPDIR/ $CDDIR 
echo "Unmounting iso...."
umount $LOOPDIR
} 

function checkRoot() {
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

}


getDebianOs
checkRoot
copySeed
copyImage
hackInitrd
hackInitrdGtk
createExeApps
copyApps
changeTimeout
generateISO
#cleanup
