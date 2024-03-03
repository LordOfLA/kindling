#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

rsync -avh /usr/etc/fan2go/ /etc/fan2go
rsync -avh /usr/etc/modules-load.d/ /etc/modules-load.d
rsync -avh /usr/etc/nvidia-container-runtime/ /etc/nvidia-container-runtime
rsync -avh /usr/etc/sway/ /etc/sway
rsync -avh /usr/etc/sysconfig/ /etc/sysconfig
rsync -avh /usr/etc/udev/ /etc/udev
rsync -avh /usr/etc/yum.repos.d/ /etc/yum.repos.d
