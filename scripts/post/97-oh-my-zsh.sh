#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

HOME=/tmp RUNZSH=no CHSH=no ZSH=/usr/lib/ohmyzsh \
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
&& set -x \
&& wget -qO /usr/lib/ohmyzsh/custom/kube-ps1.plugin.zsh \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/kube-ps1/kube-ps1.plugin.zsh \
&& mv /usr/share/zsh/*.zsh /usr/lib/ohmyzsh/custom/ \
&& git clone https://github.com/zsh-users/zsh-history-substring-search \
 /usr/lib/ohmyzsh/custom/plugins/zsh-history-subscring-search \
&& git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
 /usr/lib/ohmyzsh/custom/plugins/zsh-syntax-highlighting \
&& chsh -s /usr/bin/zsh root \
&& echo 'PATH=~/bin:~/.bin:~/.local/bin:~/.opt/bin:$PATH' >> /usr/etc/zshenv \
&& sed -i 's|^SHELL=.*|SHELL=/usr/bin/zsh|' /etc/default/useradd \
# ${VARIANT_ID^} is not posix compliant and is not parsed correctly by zsh \
&& sed -i 's/VARIANT_ID^/VARIANT_ID/' /etc/profile.d/toolbox.sh