#!/bin/bash
#此脚本用来 DIY ROM 用
#制作者：陈云
PATH=/bin:/sbin:/usr/bin:usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:~/yun:.
export PATH
set -x
set -e

TARGET_FILE="/tmp/bootimg.config"
LAST_FILE="/tmp/bootimage.conf"
if [[ -f $TARGET_FILE ]]; then
	rm $TARGET_FILE
fi
if [[ -f $LAST_FILE ]]; then
	rm $LAST_FILE
fi
cp tools/boot_info $1 tools/umkbootimg /tmp/
cd /tmp/
./umkbootimg $1 > $TARGET_FILE
./boot_info $1 >> $TARGET_FILE
rm boot_info $1 umkbootimg initramfs.cpio.gz zImage
cd -
sed -i -e "/\*/d;/\-\-\-\-\-\-/d" $TARGET_FILE
for i in "unmkbootimg" "Kernel size" "Ramdisk size" "Secondary size" "Board name" "WARNING" "Extracting" "mkbootimg" "done" "recompile" "new_boot" "RAMDISK" "CMDLINE" "PAGE" "^$"
do
sed -i "/$i/d" $TARGET_FILE
done

while read line
do
	name=`echo $line | awk '{print $1}'`

	address=`echo $line | awk '{print $3}'`
	# echo $name
	 if [[ $name == Command ]]
	 	then
	 	address=\'`echo $line | awk -F \" '{print $2}'`\'
	 fi
	 if [[ $address == "address" ]]; then
	 	address=`echo $line | awk '{print $4}'`
	 	name=tags_offset
	 fi
	  if [[ $address == "size" ]]; then
	 	address=`echo $line | awk '{print $4}'`
	 	name=pagesize
	 fi

	 case "$name" in
	 	"BASE" )name=base;;
	 	"Kernel" )name=kernel_offset;;
		"Ramdisk" )name=ramdisk_offset;;
		"Secondary" )name=second_offset;;
		"Command" )name=cmdline;;
	 esac
	 echo "$name=$address" >> $LAST_FILE
	 echo "$name=$address"
done<$TARGET_FILE
. $LAST_FILE
if [[ ! -f zImage ]]; then
	echo -e "\033[31mThis is No Kernel found, Please  put kernel in this dictory and rename as \"zImage\"\033[0m"
	exit
fi
if [[ ! -f new-initramfs.cpio.gz ]]; then
	echo -e "\033[33mNo Ramdisk found! Trying to repack ramdisk...... \033[0m"
	if [[ ! -d ramdisk ]]; then
		echo -e "\033[31mNo Ramdisk folder found!Please put ramdisk package in this dictory and rename as \"new-initramfs.cpio.gz\" \n OR put ramdisk folder in this dictory and rename as \"ramdisk\" \031[0m"
		exit
	fi
	tools/repack_ramdisk ramdisk new-initramfs.cpio.gz
fi

 tools/mkbootimg --kernel zImage --ramdisk new-initramfs.cpio.gz --pagesize $pagesize --base $base --kernel_offset $kernel_offset --ramdisk_offset $ramdisk_offset --second_offset $second_offset --tags_offset $tags_offset --cmdline "${cmdline}" -o new_boot.img
if [[ $? == 1 ]]; then
 	echo -e "\033[31msome error happend ! please see the infomation \033[0m"
 else
 	echo -e "\033[32mnew bootimg repack complete !!======>  $pwd/new_boot.img\033[0m"
 fi
rm $TARGET_FILE
rm $LAST_FILE

