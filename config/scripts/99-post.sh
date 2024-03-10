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

sed -i 's/#DefaultLimitNOFILE=/DefaultLimitNOFILE=4096:524288/' /etc/systemd/user.conf && \
    sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
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

curl -Lo /tmp/starship.tar.gz "https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz" && \
  tar -xzf /tmp/starship.tar.gz -C /tmp && \
  install -c -m 0755 /tmp/starship /usr/bin && \
  echo 'eval "$(starship init bash)"' >> /etc/bashrc

wget https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -O /usr/libexec/brew-install && \
    chmod +x /usr/libexec/brew-install

fc-cache -f /usr/share/fonts/ubuntu && \
    fc-cache -f /usr/share/fonts/inter

curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/latest/download/kind-$(uname)-amd64" && \
    chmod +x ./kind && \
    mv ./kind /usr/bin/kind

wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx -O /usr/bin/kubectx && \
    wget https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens -O /usr/bin/kubens && \
    chmod +x /usr/bin/kubectx /usr/bin/kubens

wget https://raw.githubusercontent.com/redhat-developer/devspaces/crw-2.15-rhel-8/product/containerExtract.sh -O /tmp/containerExtract.sh && \
    chmod +x /tmp/containerExtract.sh

/tmp/containerExtract.sh cgr.dev/chainguard/dive:latest --tar-flags */dive && chmod +x /tmp/cgr.dev*/usr/bin/dive && cp /tmp/cgr.dev*/usr/bin/dive /usr/bin/dive && rm -rf /tmp/cgr.dev*
/tmp/containerExtract.sh cgr.dev/chainguard/flux:latest --tar-flags */flux && chmod +x /tmp/cgr.dev*/usr/bin/flux && cp /tmp/cgr.dev*/usr/bin/flux /usr/bin/flux && rm -rf /tmp/cgr.dev*
/tmp/containerExtract.sh cgr.dev/chainguard/helm:latest --tar-flags */helm && chmod +x /tmp/cgr.dev*/usr/bin/helm && cp /tmp/cgr.dev*/usr/bin/helm /usr/bin/helm && rm -rf /tmp/cgr.dev*
/tmp/containerExtract.sh cgr.dev/chainguard/ko:latest --tar-flags */ko && chmod +x /tmp/cgr.dev*/usr/bin/ko && cp /tmp/cgr.dev*/usr/bin/ko /usr/bin/ko && rm -rf /tmp/cgr.dev*
/tmp/containerExtract.sh cgr.dev/chainguard/minio-client:latest --tar-flags */mc && chmod +x /tmp/cgr.dev*/usr/bin/mc && cp /tmp/cgr.dev*/usr/bin/mc /usr/bin/mc && rm -rf /tmp/cgr.dev*
/tmp/containerExtract.sh cgr.dev/chainguard/kubectl:latest --tar-flags */kubectl && chmod +x /tmp/cgr.dev*/usr/bin/kubectl && cp /tmp/cgr.dev*/usr/bin/kubectl /usr/bin/kubectl && rm -rf /tmp/cgr.dev*

wget https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -O /tmp/docker-compose && \
    install -c -m 0755 /tmp/docker-compose /usr/bin

curl -L -o devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64" && sudo install -c -m 0755 devpod /usr/bin && rm -f devpod

systemctl unmask fan2go.service
systemctl enable fan2go.service
systemctl unmask lm_sensors.service
systemctl enable lm_sensors.service
systemctl enable rpm-ostree-countme.service
systemctl unmask cockpit.service
systemctl enable cockpit.service

systemctl --global enable docker.socket && \
    systemctl enable swtpm-workaround.service && \
    systemctl disable pmie.service && \
    systemctl disable pmlogger.service

rm -f /etc/yum.repos.d/tailscale.repo && \
    rm -f /etc/yum.repos.d/charm.repo
rm -f /etc/yum.repos.d/terra.repo
rm -f /etc/yum.repos.d/ganto-lxc4-fedora-*.repo
rm -f /etc/yum.repos.d/vscode.repo
rm -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo
rm -f /etc/yum.repos.d/fedora-cisco-openh264.repo

rm -f /etc/yum.repos.d/ublue-os-staging-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    rm -f /etc/yum.repos.d/ganto-lxc4-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    rm -f /etc/yum.repos.d/karmab-kcli-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    rm -f /etc/yum.repos.d/atim-ubuntu-fonts-fedora-"${FEDORA_MAJOR_VERSION}".repo && \
    rm -f /etc/yum.repos.d/vscode.repo && \
    rm -f /etc/yum.repos.d/docker-ce.repo && \
    rm -f /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:phracek:PyCharm.repo && \
    rm -f /etc/yum.repos.d/fedora-cisco-openh264.repo && \
    fc-cache --system-only --really-force --verbose && \
    rm -rf /tmp/* /var/*
