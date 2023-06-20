#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

systemctl unmask dconf-update.service
systemctl enable dconf-update.service
systemctl enable rpm-ostree-countme.service
systemctl enable tailscaled.service

fc-cache -f /usr/share/fonts/ubuntu

rm -f /etc/yum.repos.d/tailscale.repo
rm -f /etc/yum.repos.d/terra.repo
rm -f /etc/yum.repos.d/ganto-lxc4-fedora-"${FEDORA_MAJOR_VERSION}".repo
rm -f /etc/yum.repos.d/vscode.repo
rm -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo
rm -f /etc/yum.repos.d/fedora-cisco-openh264.repo

sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf
sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf

curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/v0.20.0/kind-linux-amd64"
chmod +x ./kind
mv ./kind /usr/bin/kind

curl -L -o fan2go https://github.com/markusressel/fan2go/releases/latest/download/fan2go-linux-amd64
chmod +x fan2go
mv ./fan2go /usr/bin/fan2go

curl -L -o fan2go.service https://raw.githubusercontent.com/markusressel/fan2go/master/fan2go.service
mv ./fan2go.service /usr/lib/systemd/system

systemctl unmask fan2go.service
systemctl enable fan2go.service