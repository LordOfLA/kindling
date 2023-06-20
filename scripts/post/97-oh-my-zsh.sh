#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail

HOME=/tmp RUNZSH=no CHSH=no ZSH=/usr/lib/ohmyzsh \
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
&& set -x \
&& git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-/usr/lib/ohmyzsh/custom}/themes/powerlevel10k \
&& wget -qO /usr/lib/ohmyzsh/custom/kube-ps1.plugin.zsh \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/kube-ps1/kube-ps1.plugin.zsh \
&& git clone https://github.com/zsh-users/zsh-history-substring-search \
 /usr/lib/ohmyzsh/custom/plugins/zsh-history-subscring-search \
&& git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
 /usr/lib/ohmyzsh/custom/plugins/zsh-syntax-highlighting \
&& chsh -s /usr/bin/zsh root \
&& echo 'PATH=~/bin:~/.bin:~/.local/bin:~/.opt/bin:$PATH' >> /usr/etc/zshenv \
&& sed -i 's|^SHELL=.*|SHELL=/usr/bin/zsh|' /etc/default/useradd
