#!/bin/sh
#
# /usr/local/sbin/lxd-snap-workaround.sh
#
# https://forum.snapcraft.io/t/snapd-apparmor-profiles-not-being-applied-in-lxd-containers-with-lxc-apparmor-profile-unconfined-when-host-is-rebooted/5818/8
/usr/sbin/apparmor_parser -r /var/lib/snapd/apparmor/profiles/*
exit
