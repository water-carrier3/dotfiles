if ! test -f aliases/.bash_aliases.d/00-rlwrap_scripts.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/aliases/.bash_aliases.d/00-rlwrap_scripts.sh)" 
else
    . ./aliases/.bash_aliases.d/00-rlwrap_scripts.sh
fi

if ! test -f checks/check_system.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_system.sh)" 
else
    . checks/check_system.sh
fi

if ! type list-ppa &> /dev/null; then
    printf "${CYAN}list-ppa${normal} is not installed (python cmd tool for listing ppas from 'launchpad.net'\n"
    reade -Q 'GREEN' -i 'y' -p "Install list-ppa? [Y/n]: " 'n' ppa_ins
    if test $ppa_ins == 'y'; then
        if ! type pipx &> /dev/null; then
            if ! test -f install_pipx.sh; then
                eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/install_pipx.sh)" 
            else
                ./install_pipx.sh
            fi  
        fi

        if ! type pipx &> /dev/null && test -f $HOME/.local/bin/pipx; then 
            $HOME/.local/bin/pipx install list-ppa 
        elif type pipx &> /dev/null; then 
            pipx install list-ppa
        fi

        if ! test -f ~/.config/ppas; then 
            reade -Q 'GREEN' -i 'y' -p "Run list-ppa (generates file containin ppas that have a release file for your version in ~/.config/ppas - !! Can take a while - can be rerun)? [Y/n]: " 'n' ppa_ins
            if test $ppa_ins == 'y'; then
                if ! type list-ppa &> /dev/null; then
                    $HOME/.local/bin/list-ppa --file ~/.config/ppas 
                else
                    list-ppa --file ~/.config/ppas
                fi
            fi 
        fi 
    fi
    unset ppa_ins 
fi

