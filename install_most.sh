if ! test -f checks/check_system.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_distro)" 
else
    . ./checks/check_system.sh
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

if ! test -f checks/check_envvar.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_envvar.sh)" 
else
    . ./checks/check_envvar.sh
fi
if ! test -f aliases/.bash_aliases.d/00-rlwrap_scripts.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/aliases/.bash_aliases.d/00-rlwrap_scripts.sh)" 
else
    . ./aliases/.bash_aliases.d/00-rlwrap_scripts.sh
fi

answer=""
if [ ! -x "$(command -v most)" ]; then
    if test $distro_base == "Debian" ; then
        eval "$pac_ins most"
    elif test $distro == "Arch" || test $distro == "Manjaro"; then
        eval "$pac_ins most"
    fi
fi

most=$(whereis most)
reade -Q "GREEN" -i "y" -p "Set most default pager for $USER? [Y/n]: " "n" most_usr
if [ "y" == "$most_usr" ]; then
    if grep -q "MOST" $ENVVAR; then 
        sed -i "s|.export MOST_SWITCHES=|export MOST_SWITCHES=|g" $ENVVAR 
        sed -i "s|.export PAGER=|export PAGER=|g" $ENVVAR
        sed -i "s|export PAGER=.*|export PAGER=$most|g" $ENVVAR
        sed -i "s|.export SYSTEMD_PAGER=.*|export SYSTEMD_PAGER=\$PAGER|g" $ENVVAR
        sed -i "s|.export SYSTEMD_PAGERSECURE=.*|export SYSTEMD_PAGERSECURE=1|g" $ENVVAR
    else
        printf "export PAGER=$most\n" >> $ENVVAR
        printf "export SYSTEMD_PAGER=\$PAGER" >> $ENVVAR
        printf "export SYSTEMD_PAGERSECURE=1" >> $ENVVAR
    fi
fi
    
reade -Q "YELLOW" -i "y" -p "Set most default pager for root? [Y/n]: " "n" most_root
if [ "y" == "$most_root" ]; then
    if sudo grep -q "MOST" $ENVVAR_R; then
        sudo sed -i "s|.export MOST_SWITCHES=.*|export MOST_SWITCHES=.*|g" $ENVVAR_R 
        sudo sed -i "s|.export PAGER=.*|export PAGER=$most|g" $ENVVAR_R
        sudo sed -i "s|.export SYSTEMD_PAGER=.*|export SYSTEMD_PAGER=$PAGER|g" $ENVVAR_R
        sudo sed -i "s|.export SYSTEMD_PAGERSECURE=.*|export SYSTEMD_PAGERSECURE=1|g" $ENVVAR_R
    else
        printf "export PAGER=$most\n" | sudo tee -a $ENVVAR_R
        printf "export SYSTEMD_PAGER=\$PAGER\n" | sudo tee -a $ENVVAR_R
        printf "export SYSTEMD_PAGERSECURE=1\n" | sudo tee -a $ENVVAR_R
    fi
fi
