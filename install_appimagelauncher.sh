#!/usr/bin/env bash
if ! test -f checks/check_system.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_system.sh)" 
else
    . ./checks/check_system.sh
fi

if ! test -f checks/check_appimage_ready.sh; then
    eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_appimage_ready.sh)" 
else
    . ./checks/check_appimage_ready.sh
fi

if ! test -f aliases/.bash_aliases.d/package_managers.sh; then
    eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/aliases/.bash_aliases.d/package_managers.sh)" 
else
    source aliases/.bash_aliases.d/package_managers.sh
fi


if ! type AppImageLauncher &> /dev/null; then
    echo "This next $(tput setaf 1)sudo$(tput sgr0) will install Appimagelauncher"
    if test $distro_base == "Arch" ; then 
        eval "$pac_ins appimagelauncher"
    elif test $distro_base == "Debian"; then
        if type add-apt-repository &> /dev/null && [[ $(check-ppa ppa:appimagelauncher-team/stable) =~ 'OK' ]]; then
            sudo add-apt-repository ppa:appimagelauncher-team/stable
            eval "$pac_up"
            eval "$pac_ins appimagelauncher" 
        else
            #if ! $(apt search libfuse2t64 &> /dev/null | awk 'NR>2 {print;}'); then
            #    eval "$pac_ins libfuse2t64 -y "
            #fi
            if ! $(apt search jq &> /dev/null | awk 'NR>2 {print;}'); then
                eval "$pac_ins jq -y "
            fi
            tmpd=$(mktemp -d)
            tag=$(curl -sL https://api.github.com/repos/TheAssassin/AppImageLauncher/releases/latest | jq -r ".tag_name") 
            ltstv=$(curl -sL https://api.github.com/repos/TheAssassin/AppImageLauncher/releases/latest | jq -r ".assets" | grep --color=never "name" | sed 's/"name"://g' | tr '"' ' ' | tr ',' ' ' | sed 's/[[:space:]]//g')
            code_name='bionic' 
            if ! test -z && [[ $release < 16.04 ]] || [[ $release == 16.04 ]]; then
                code_name='xenial'
            fi
            file=$(echo "$ltstv" | grep --color=never $code_name"_"$arch) 

            wget -P $tmpd https://github.com/TheAssassin/AppImageLauncher/releases/download/$tag/$file
            sudo dpkg -i $tmpd/$file 
            sudo apt --fix-broken install -y
            sudo systemctl restart systemd-binfmt 
            unset tmpd tag ltstv code_name file 
        fi
    fi
fi

