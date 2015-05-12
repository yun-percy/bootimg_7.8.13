#!/bin/bash
#此脚本用来 DIY ROM 用
#制作者：陈云
PATH=/bin:/sbin:/usr/bin:usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:~/yun:.
export PATH

set -x
set -e

tools/umkbootimg $1
tools/unpack_ramdisk initramfs.cpio.gz


