if ! test -f checks/check_system.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_system.sh)" 
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

if ! type reade &> /dev/null; then
   if ! test -f aliases/.bash_aliases.d/00-rlwrap_scripts.sh; then
         eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_rlwrap.sh)" 
    else
        . ./checks/check_rlwrap.sh
   fi
fi 


#if test $distro_base == "Debian"; then
#   eval "$pac_ins neofetch"
#
if test $distro == "Manjaro"; then
   pamac install manjaro-settings-samba
   if type thunar &> /dev/null; then
        pamac install thunar-shares-plugin
   fi
fi

