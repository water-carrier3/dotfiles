if ! test -f checks/check_system.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_system.sh)" 
else
    . ./checks/check_system.sh
fi
if ! test -f aliases/.bash_aliases.d/00-rlwrap_scripts.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/aliases/.bash_aliases.d/00-rlwrap_scripts.sh)" 
else
    . ./aliases/.bash_aliases.d/00-rlwrap_scripts.sh
fi 

if ! test -f checks/check_envvar.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_envvar.sh)" 
else
    . ./checks/check_envvar.sh
fi
if ! test -f checks/check_keybinds.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_keybinds.sh)" 
else
    . ./checks/check_keybinds.sh
fi

if ! type update-system &> /dev/null; then
    if ! test -f aliases/.bash_aliases.d/update-system.sh; then
        eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/aliases/.bash_aliases.d/update-system.sh)" 
    else
        . ./aliases/.bash_aliases.d/update-system.sh
    fi
fi

if test -z $SYSTEM_UPDATED; then
    reade -Q "CYAN" -i "y" -p "Update system? [Y/n]: " "n" updatesysm
    if test $updatesysm == "y"; then
        update-system                     
    fi
fi 

if ! type autojump &> /dev/null; then
    if test "$distro_base" == "Arch"; then
        if test -z "$AUR_ins"; then 
            reade -Q 'GREEN' -i 'y' -p 'No AUR helper found. Install yay? [Y/n]: ' 'n' ins_yay
            if test $ins_yay == 'y'; then
                if ! test -f AUR_insers/install_yay.sh ; then
                     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/aliases/.bash_aliases.d/AUR_insers/install_yay.sh )" 
                else
                    . ./AUR_insers/install_yay.sh 
                fi 
            fi
            unset ins_yay
            yay -S autojump 
        else 
            eval "$AUR_ins autojump"
        fi
    elif [ $distro_base == "Debian" ]; then
        eval "$pac_ins autojump"                                                              
    fi
fi

if ! grep -q "autojump" ~/.bashrc; then
    printf "[ -s /etc/profile.d/autojump.sh ] && source /etc/profile.d/autojump.sh\n" >> ~/.bashrc
&> /dev/null
fi
if ! sudo grep -q "autojump" /root/.bashrc; then
    printf "[ -s /etc/profile.d/autojump.sh ] && source /etc/profile.d/autojump.sh\n" | sudo tee -a /root/.bashrc &> /dev/null
fi

unset tojump bnd bnd_r
