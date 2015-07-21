#!/bin/bash
#
#    Create a Plain Keyfile for use with LUKS
#    Copyright (C) 2015  Nexor
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
## Configure LUKS partition here BEFORE running script: 
luks_vol="/dev/sda2"

if [ ! -d /usr/share/dracut/modules.d/50plymouth-tpm ]; then
	echo "Please install TPM-LUKS first.."
	exit 1
fi

dd if=/dev/random of=/usr/share/dracut/modules.d/50plymouth-tpm/plain_key bs=1 count=32
read -p "Please enter any existing LUKS passphrase: " pphrase
echo "$pphrase" | cryptsetup luksAddKey $luks_vol /usr/share/dracut/modules.d/50plymouth-tpm/plain_key --batch-mode
## Update Initramfs to include new keyfile: 
dracut --force
