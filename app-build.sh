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

#!/bin/bash
APPS_DIR=$PWD/apps
OUT_DIR=$PWD/output/
LOOPDIR=$OUT_DIR/__loopdir__
CDDIR=$OUT_DIR/__cd__
IRDIR=$OUT_DIR/__irmod__
ISO=$PWD/iso/debian-8.3.0-amd64-lxde-CD-1.iso
OUTPUTISO=$PWD/output/Felix2go.iso
PRESEED_CFG=$PWD/iso/felix-preseed.cfg
NEW_PRESEED_CFG=$PWD/iso/new-preseed.cfg
TMPF=/tmp/tmp_preseed.txt
MAKE_SELF=$PWD/makeself/makeself.sh
echo "Generating Apps"



function createExeApps() {
cd $APPS_DIR
for i in $(ls -d *); 
do 
    echo "Compressing... " ${i}; 
    $MAKE_SELF ${i} $OUT_DIR/${i}.run "${i}" ./postinstall.sh >/dev/null 2>&1
done
} 

createExeApps
