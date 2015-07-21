#!/bin/sh

# do not ask, if we already have root
[ -f /sysroot/proc ] && exit 0

# check if destination already exists
[ -b /dev/mapper/$2 ] && exit 0

# we already asked for this device
[ -f /tmp/cryptroot-asked-$2 ] && exit 0

. /lib/dracut-lib.sh

# default luksname - luks-UUID
luksname=$2

# if device name is /dev/dm-X, convert to /dev/mapper/name
if [ "${1##/dev/dm-}" != "$1" ]; then
    device="/dev/mapper/$(dmsetup info -c --noheadings -o name "$1")"
else
    device="$1"
fi

if [ -f /etc/crypttab ] && ! getargs rd_NO_CRYPTTAB; then
    while read name dev rest; do
	# ignore blank lines and comments
	if [ -z "$name" -o "${name#\#}" != "$name" ]; then
	    continue
	fi

	# UUID used in crypttab
	if [ "${dev%%=*}" = "UUID" ]; then
	    if [ "luks-${dev##UUID=}" = "$2" ]; then
		luksname="$name"
		break
	    fi
	
	# path used in crypttab
	else
	    cdev=$(readlink -f $dev)
	    mdev=$(readlink -f $device)
	    if [ "$cdev" = "$mdev" ]; then
		luksname="$name"
		break
	    fi
	fi
    done < /etc/crypttab
    unset name dev rest
fi

prompt="TPM NVRAM password for [$device ($luksname)]:"
if [ ${#luksname} -gt 8 ]; then
    sluksname=${sluksname##luks-}
    sluksname=${luksname%%${luksname##????????}}
    prompt="TPM NVRAM password for $device ($sluksname...)"
fi

#
# IRT@Nexor - we need to check for PCR composites, to determine if we try TPM-based LUKS unlock or not.. 
# IRT@Nexor - script fragment borrowed from cryptroot-ask-tpm.sh.. 
GETCAP=/usr/bin/getcapability
AWK=/bin/awk
TPM_LUKS_MAX_NV_INDEX=128
VIABLE_INDEXES=""
# An index is viable if its composite hash matches current PCR state, or if
# it doesn't require PCR state at all
#
ALL_INDEXES=$($GETCAP -cap 0xd | ${AWK} -F: '$1 ~ /Index/ {print $2 }' | ${AWK} -F= '{ print $1 }')
for i in $ALL_INDEXES; do
	MATCH1=$($GETCAP -cap 0x11 -scap $i | ${AWK} -F ": " '$1 ~ /Matches/ { print $2 }')
	if [ -n "${MATCH1}" -a "${MATCH1}" = "Yes" ]; then
		# Add this index at the beginning, since its especially likely to be
		# the index we're looking for
		VIABLE_INDEXES="$i $VIABLE_INDEXES"
		echo "PCR composite matches for index: $i"
		continue
	elif [ $i -gt ${TPM_LUKS_MAX_NV_INDEX} ]; then
		continue
	fi

	# Add this index at the end of the list
	VIABLE_INDEXES="$VIABLE_INDEXES $i"
	echo "Viable index: $i"
done

# IRT@Nexor - our default keyfile location:
KEYFILE=/plain_key

# flock against other interactive activities
{ flock -s 9;
	# IRT@Nexor - If we found some viable TPM indexes, try TPM-LUKS unlock first.. 
	if [ "$VIABLE_INDEXES" != "" ]; then
		# IRT@Nexor - Attempt passwordless key release first.. 
		/sbin/cryptroot-dontask-tpm $device $luksname
		# IRT@Nexor - If still no joy, request a password.. 
		if [ $? -ne 0 ]; then
			/bin/plymouth ask-for-password \
				--number-of-tries=3 \
			--prompt "$prompt" \
			--command="/sbin/cryptroot-ask-tpm $device $luksname"
		fi
	else
		echo "WARNING: Nexor strongly recommends sealing this system to it's TPM!"
		echo "Enable / own your TPM and run 'tpm-luks-init' from maintenance mode"
		echo "No viable TPM indexes found, falling back to LUKS keyfile / passphrase.."
		# IRT@Nexor - First attempt to use our default keyfile if it exists.. 
		if [ -f $KEYFILE ]; then
		/sbin/cryptsetup luksOpen -T1 $device $luksname --key-file=$KEYFILE --batch-mode
		else
		# IRT@Nexor - Finally, attempt using LUKS passphrase direct.. 
			prompt="LUKS password for [$device ($luksname)]:"
			/bin/plymouth ask-for-password \
				--prompt "$prompt" \
				--command="/sbin/cryptsetup luksOpen -T1 $device $luksname"
		fi
	fi
	if [ $? -ne 0 ]; then
		# IRT@Nexor - First attempt to use our default keyfile if it exists.. 
		if [ -f $KEYFILE ]; then
		/sbin/cryptsetup luksOpen -T1 $device $luksname --key-file=$KEYFILE --batch-mode
		else
		# IRT@Nexor - Finally, attempt using LUKS passphrase direct.. 
			prompt="LUKS password for [$device ($luksname)]:"
			/bin/plymouth ask-for-password \
				--prompt "$prompt" \
				--command="/sbin/cryptsetup luksOpen -T1 $device $luksname"
		fi
	fi
} 9>/.console.lock

unset ask device luksname

# mark device as asked
>> /tmp/cryptroot-asked-$2

udevsettle

exit 0
# vim:ts=8:sw=4:sts=4:et
