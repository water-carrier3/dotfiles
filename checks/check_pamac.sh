if ! test -f aliases/.bash_aliases.d/00-rlwrap_scripts.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/aliases/.bash_aliases.d/00-rlwrap_scripts.sh)" 
else
    . ./aliases/.bash_aliases.d/00-rlwrap_scripts.sh
fi 


if grep -q "#EnableAUR" /etc/pamac.conf; then
    reade -Q "GREEN" -i "y" -p "Enable AUR for pamac? [Y/n]: " "n" aurset
    if [ "$aurset" == "y" ]; then
        sudo sed -i 's|#EnableAUR|EnableAUR|g' /etc/pamac.conf 
    fi
    unset aurset
fi

#if grep -q "#KeepBuiltPkgs" /etc/pamac.conf; then
#    reade -Q "GREEN" -i "y" -p "Keep build AUR packages? [Y/n]:" "n" aurset1
#    if [ "$aurset1" == "y" ]; then
#        sudo sed -i 's|#KeepBuiltPkgs|KeepBuiltPkgs|g' /etc/pamac.conf 
#    fi
#    unset aurset1
#fi

if grep -q "#CheckAURUpdates" /etc/pamac.conf; then
    reade -Q "GREEN" -i "y" -p "Enable updatecheck for AUR packages? [Y/n]: " "n" aurset1
    if [ "$aurset1" == "y" ]; then
        sudo sed -i 's|#CheckAURUpdates|CheckAURUpdates|g' /etc/pamac.conf 
    fi
    unset aurset1    
fi

if grep -q "#CheckAURVCSUpdates" /etc/pamac.conf; then
    reade -Q "GREEN" -i "y" -p "Enable updatecheck for AUR Development packages? [Y/n]: " "n" aurset1
    if [ "$aurset1" == "y" ]; then
        sudo sed -i 's|#CheckAURVCSUpdates|CheckAURVCSUpdates|g' /etc/pamac.conf 
    #elif [ "$aurset1" == "n" ]; then  
    #    sudo sed -i 's|CheckAURVCSUpdates|#CheckAURVCSUpdates|g' /etc/pamac.conf
    fi
    unset aurset1
fi
if type flatpak &> /dev/null && grep -q "#EnableFlatpak" /etc/pamac.conf; then
    reade -Q "GREEN" -i "y" -p "Enable flatpak in pamac? [Y/n]: " "n" fltpak
    if [ "$fltpak" == "y" ]; then
        eval "$pac_ins libpamac-flatpak-plugin"
        sudo sed -i 's|#EnableFlatpak|EnableFlatpak|g' /etc/pamac.conf 

        if grep -q "#CheckFlatpakUpdates" /etc/pamac.conf; then
            reade -Q "GREEN" -i "y" -p "Enable updatecheck for flatpak updates? [Y/n]: " "n" fltpak1
            if [ "$fltpak1" == "y" ]; then
                sudo sed -i 's|#CheckFlatpakUpdates|CheckFlatpakUpdates|g' /etc/pamac.conf 
            fi
            unset fltpak1
        fi
        unset fltpak
    fi
fi

if type snap &> /dev/null && grep -q "#EnableSnap" /etc/pamac.conf; then
    reade -Q "GREEN" -i "y" -p "Enable snap in pamac? [Y/n]:" "n" snap
    if [ "$snap" == "y" ]; then
        eval "$pac_ins libpamac-snap-plugin"
        sudo sed -i 's|#EnableSnap|EnableSnap|g' /etc/pamac.conf 
    fi
    unset snap
fi
