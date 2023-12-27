#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

# --- helper functions for logs ---
info()
{
    echo '[INFO] ' "$@"
}
warn()
{
    echo '[WARN] ' "$@" >&2
}
fatal()
{
    echo '[ERROR] ' "$@" >&2
    exit 1
}

rm -f /etc/yum.repos.d/tailscale.repo
rm -f /etc/yum.repos.d/terra.repo
rm -f /etc/yum.repos.d/ganto-lxc4-fedora-*.repo
rm -f /etc/yum.repos.d/vscode.repo
rm -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo
rm -f /etc/yum.repos.d/fedora-cisco-openh264.repo

sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf
sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf

rpm_site="rpm.rancher.io"
rpm_channel=stable
rpm_target=el8
available_version="k3s-selinux-1.2-2.${rpm_target}.noarch.rpm"
version=$(timeout 5 curl -s https://api.github.com/repos/k3s-io/k3s-selinux/releases/latest |  grep browser_download_url | awk '{ print $2 }' | grep -oE "[^\/]+${rpm_target}\.noarch\.rpm")
if [ "${version}" == "" ]; then
    warn "Failed to get available versions of k3s-selinux..defaulting to ${available_version}"
    return
fi
available_version=${version}
rpm_url="https://${rpm_site}/k3s/${rpm_channel}/common/centos/8/noarch/${available_version}"

curl -o k3s-selinux.rpm -sfL $rpm_url

rpm-ostree --idempotent install -y ./k3s-selinux.rpm

# curl -sfL https://get.k3s.io | sudo INSTALL_K3S_SKIP_START=true INSTALL_K3S_SKIP_SELINUX_RPM=true INSTALL_K3S_SYSTEMD_DIR=/usr/lib/systemd/system INSTALL_K3S_BIN_DIR=/usr/bin sh -

# Use binary in repo for now. Figure out how to RPM it later
# curl -L -o fan2go https://github.com/markusressel/fan2go/releases/latest/download/fan2go-linux-amd64
# chmod +x fan2go
# mv ./fan2go /usr/bin/fan2go

curl -L -o fan2go.service https://raw.githubusercontent.com/markusressel/fan2go/master/fan2go.service
mv ./fan2go.service /usr/lib/systemd/system

systemctl unmask fan2go.service
systemctl enable fan2go.service
systemctl unmask lm_sensors.service
systemctl enable lm_sensors.service
systemctl unmask dconf-update.service
systemctl enable dconf-update.service
systemctl enable rpm-ostree-countme.service
systemctl enable tailscaled.service
systemctl unmask cockpit.service
systemctl enable cockpit.service
