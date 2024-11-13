# !/bin/bash

if ! test -f checks/check_system.sh.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_system.sh)" 
else
    . ./checks/check_system.sh
fi

if ! test -f checks/check_envvar_aliases_completions_keybinds.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_envvar_aliases_completions_keybinds.sh)" 
else
    . ./checks/check_envvar_aliases_completions_keybinds.sh
fi

if ! test -f aliases/.bash_aliases.d/00-rlwrap_scripts.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/aliases/.bash_aliases.d/00-rlwrap_scripts.sh)" 
else
    . ./aliases/.bash_aliases.d/00-rlwrap_scripts.sh
fi

if ! type update-system &> /dev/null; then
    if ! test -f aliases/.bash_aliases.d/update-system.sh; then
        eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/aliases/.bash_aliases.d/update-system.sh)" 
    else
        . ./aliases/.bash_aliases.d/update-system.sh
    fi
fi

if test -z $SYSTEM_UPDATED; then
    reade -Q "CYAN" -i "n" -p "Update system? [Y/n]: " "n" updatesysm
    if test $updatesysm == "y"; then
        update-system                     
    fi
fi


# Fzf (Fuzzy Finder)

 # Bash completion issue with fzf fix
 # https://github.com/cykerway/complete-alias/issues/46

if ! test -d ~/.fzf  || test -f ~/.fzf.bash; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install
    if [[ $ENVVAR =~ '.environment.env' ]]; then 
        sed -i 's|.export PATH=$PATH:$HOME/.fzf/bin|export PATH=$PATH:$HOME/.fzf/bin|g' $ENVVAR
    elif ! grep -q '.fzf/bin' $ENVVAR; then
        if grep -q '~/.environment.env' $ENVVAR; then
            sed -i 's|\(\[ -f ~/.environment.env\] \&\& source \~/.environment.env\)|\export PATH=$PATH:$HOME/.fzf/bin\n\n\1\n|g' ~/.bashrc
        elif grep -q '~/.bash_aliases' $ENVVAR; then
            sed -i 's|\(\[ -f ~/.bash_aliases \] \&\& source \~/.bash_aliases\)|\export PATH=$PATH:$HOME/.fzf/bin\n\n\1\n|g' ~/.bashrc
            sed -i 's|\(if \[ -f ~/.bash_aliases \]; then\)|export PATH=$PATH:$HOME/.fzf/bin\n\n\1\n|g' ~/.bashrc 
        else 
            echo 'export PATH="$PATH:$HOME/.fzf/bin"' >> $ENVVAR
        fi
    fi
    rm -v ~/.fzf.bash
    sed -i '/\[ -f \~\/.fzf.bash \] \&\& source \~\/.fzf.bash/d' ~/.bashrc
    [ ! -f ~/.bash_completion.d/fzf-completion.bash ] && ln -s ~/.fzf/shell/completion.bash ~/.bash_completion.d/fzf-completion.bash
    
    printf "${cyan}Fzf${normal} keybinds:\n\t - Fzf history on Ctrl-R (replaces reverse-search-history)\n\t - Filepath retriever on Ctrl-T\n\t - Directory navigator on Alt-C\n\t - **<TAB> for fzf completion on some commands\n"
    reade -Q "GREEN" -i "y" -p "Use fzf keybinds? [Y/n]: " "n" fzf_key
    if test $fzf_key == 'y' ; then 
        [ ! -f ~/.keybinds.d/fzf-bindings.bash ] && ln -s ~/.fzf/shell/key-bindings.bash ~/.keybinds.d/fzf-bindings.bash
    fi
fi

if test -f ~/.keybinds.d/keybinds.bash && grep -q '^bind -m emacs-standard  '\''"\\C-z": vi-undo'\''' ~/.keybinds.d/keybinds.bash; then     
    sed -i 's|\\\C-z|\\\C-o|g' ~/.fzf/shell/key-bindings.bash; 
fi

unset fzf_key
export PATH="$PATH:$HOME/.fzf/bin"

if [ ! -f ~/.fzf_history ]; then
    touch ~/.fzf_history 
fi

fnd="find"

# TODO: Make better check: https://github.com/sharkdp/fd
if ! type fd-find &> /dev/null && ! type fd &> /dev/null; then
    reade -Q "GREEN" -i "y" -p "Install fd and use for fzf? (Faster find) [Y/n]: " "n" fdr
    if [ -z $fdr ] || [ "Y" == $fdr ] || [ $fdr == "y" ]; then
        if ! test -f install_fd.sh; then
            eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/install_fd.sh)" 
        else
            ./install_fd.sh
        fi 
    fi
fi

if type fd-find &> /dev/null || type fd &> /dev/null; then
    fnd="fd"
fi

# BAT
if ! type bat &> /dev/null; then
    reade -Q "GREEN" -i "y" -p "Install bat? (File previews/thumbnails for riflesearch) [Y/n]: " "n" bat
    if [ "$bat" == "y" ]; then
        if ! test -f install_bat.sh; then
            eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/install_bat.sh)" 
        else
            ./install_bat.sh
        fi
    fi
    unset bat 
fi

# TREE
if ! type tree &> /dev/null; then
    reade -Q "GREEN" -i "y" -p "Install tree? (Builtin cd shortcut gets a nice directory tree preview ) [Y/n]: " "n" tree
    if [ "$tree" == "y" ]; then
        if ! test -f install_tree.sh; then
            eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/install_tree.sh)" 
        else
            ./install_tree.sh
        fi
    fi
    unset tree
fi

#TODO: fzf-rifle.sh still has ffmpegthumbnailer part (could use sed check)
if ! type ffmpegthumbnailer &> /dev/null; then 
    reade -Q "GREEN" -i "y" -p "Install ffmpegthumbnailer? (Video thumbnails for riflesearch) [Y/n]: " "n" ffmpg
    if [ "$ffmpg" == "y" ]; then
        if ! test -f install_ffmpegthumbnailer.sh; then
            eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/install_ffmpegthumbnailer.sh)" 
        else
            ./install_ffmpegthumbnailer.sh
        fi 
    fi
    unset ffmpg
fi

# RIPGREP
# TODO: Check export for ripgrep
# TODO: Do more with ripgrep
if ! type rg &> /dev/null; then
     reade -Q "GREEN" -i "y" -p "Install ripgrep? (Recursive grep, opens possibility for line by line fzf ) [Y/n]: " "n" rpgrp
     if [ -z $rpgrp ] || [ "Y" == $rpgrp ] || [ $rpgrp == "y" ]; then
        if ! test -f install_ripgrep.sh; then
            eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/install_ripgrep.sh)" 
        else
            ./install_ripgrep.sh
        fi
        if [ $ENVVAR == ~/.environment.env ] ; then
            sed -i 's|#export RG_PREFIX|export RG_PREFIX|g' $ENVVAR
        elif ! grep -q "export RG_PREFIX" $ENVVAR; then
            printf "\n# RIPGREP\nexport RG_PREFIX='rg --column --line-number --no-heading --color=always --smart-case \"" >> $ENVVAR &> /dev/null
        fi
        if [ $ENVVAR_R == /root/.environment.env ] ; then
            sudo sed -i 's|#export RG_PREFIX|export RG_PREFIX|g' $ENVVAR_R
        elif ! sudo grep -q "export RG_PREFIX" $ENVVAR_R; then
             printf "\n# RIPGREP\nexport RG_PREFIX='rg --column --line-number --no-heading --color=always --smart-case \"" | sudo tee -a $ENVVAR_R
        fi
        
        reade -Q "GREEN" -i "y" -p "Add shortcut for ripgrep files in dir? (Ctrl-g) [Y/n]: " "n" rpgrpdir
        if [ $rpgrpdir == "y" ]; then
            if ! test -f fzf/.bash_aliases.d/ripgrep-directory.sh; then
                curl -o ~/.bash_aliases.d/ripgrep-directory.sh https://raw.githubusercontent.com/water-carrier3/dotfiles/main/fzf/.bash_aliases.d/ripgrep-directory.sh
            else
                cp -fv fzf/.bash_aliases.d/ripgrep-directory.sh ~/.bash_aliases.d/
            fi
        fi
     fi
    unset rpgrp rpgrpdir
fi


# XCLIP
if ! type xclip &> /dev/null; then 
    reade -Q "GREEN" -i "y" -p "Install xclip? (Clipboard tool for Ctrl-R/Reverse history shortcut) [Y/n]: " "n" xclip
    if [ "$xclip" == "y" ]; then
        if ! test -f install_xclip.sh; then
            eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/install_xclip.sh)" 
        else
            ./install_xclip.sh
        fi
    fi
    if [ $ENVVAR == ~/.environment.env ] ; then
        sed -i 's|#export FZF_CTRL_R_OPTS=|export FZF_CTRL_R_OPTS=|g' $ENVVAR
    elif ! grep -q "export FZF_CTRL_R_OPTS=" $ENVVAR; then
        printf "\nexport FZF_CTRL_R_OPTS=\" --preview 'echo {}' --preview-window up:3:hidden:wrap --bind 'ctrl-t:toggle-preview' --bind 'alt-c:execute-silent(echo -n {2..} | xclip -i -sel c)+abort' --color header:italic --header 'Press ALT-C to copy command into clipboard'\"" >> $ENVVAR &> /dev/null
    fi
    if [ $ENVVAR_R == /root/.environment.env ] ; then
        sudo sed -i 's|#export FZF_CTRL_R_OPTS==|export FZF_CTRL_R_OPTS=|g' $ENVVAR_R
    elif ! sudo grep -q "export FZF_CTRL_R_OPTS" $ENVVAR_R; then
        printf "\nexport FZF_CTRL_R_OPTS=\" --preview 'echo {}' --preview-window up:3:hidden:wrap --bind 'ctrl-t:toggle-preview' --bind 'alt-c:execute-silent(echo -n {2..} | xclip -i -sel c)+abort' --color header:italic --header 'Press ALT-C to copy command into clipboard'\"" | sudo tee -a $ENVVAR_R
    fi 
fi
unset xclip


#echo "${green}Fzf will use '${CYAN}$fnd${normal}${green}'. Set default options that are fzf related to:${normal}"
#reade -Q "GREEN" -i "y" -p "    Search globally instead of in current folder? [Y/n]: " "n" fndgbl
#reade -Q "GREEN" -i "y" -p "    Search only files? [Y/n]: " "n" fndfle
#reade -Q "GREEN" -i "y" -p "    Include hidden files? [Y/n]: " "n" fndhiddn
#if [ $fnd == "find" ]; then
#   test "$fndgbl" == "y" && fnd="find /"
#   test "$fndfle" == "y" && fnd="$fnd -type f"
#   test "$fndhiddn" == "y" && fnd="$fnd -iname \".*\""
#else
#   test "$fndgbl" == "y" && fnd="fd --search-path /"
#   test "$fndfle" == "y" && fnd="$fnd --type f"
#   test "$fndhiddn" == "y" && fnd="$fnd --hidden"
#fi
#unset fndgbl fndfle fndhiddn

if [ $ENVVAR == ~/.environment.env ] ; then
    sed -i 's|#export FZF_DEFAULT_COMMAND|export FZF_DEFAULT_COMMAND|g' $ENVVAR
    sed -i 's|#export FZF_CTRL_T_COMMAND|export FZF_CTRL_T_COMMAND|g' $ENVVAR
    sed -i 's|#export FZF_CTRL_R_OPTS|export FZF_CTRL_R_OPTS|g' $ENVVAR
    sed -i 's|#export FZF_BIND_TYPES|export FZF_BIND_TYPES|g' $ENVVAR
    sed -i 's|#type fd &> /dev/null|type fd &> /dev/null|g' $ENVVAR
    sed -i 's/#--bind/--bind/' $ENVVAR
    sed -i 's/#--preview-window/--preview-window/' $ENVVAR
    sed -i 's/#--color/--color/' $ENVVAR
    if type tree &> /dev/null; then
        sed -i 's|#export FZF_ALT_C_OPTS=|export FZF_ALT_C_OPTS=|g' $ENVVAR
    fi
elif ! grep -q "export FZF_DEFAULT_COMMAND" $ENVVAR; then
    printf "\n# FZF\nexport FZF_DEFAULT_COMMAND=\"$fnd\"\nexport FZF_CTRL_T_COMMAND='$FZF_DEFAULT_COMMAND'\n" >> $ENVVAR
    if type tree &> /dev/null; then
        printf "export FZF_ALT_C_OPTS=\"--preview 'tree -C {}\"\n" >> $ENVVAR 
    fi
fi

echo "Next $(tput setaf 1)sudo$(tput sgr0) will update FZF environment variables in /root/.environment.env' "
if [ $ENVVAR_R == /root/.environment.env ] ; then
    sudo sed -i 's|#export FZF_DEFAULT_COMMAND|export FZF_DEFAULT_COMMAND |g' $ENVVAR_R
    sudo sed -i 's|#export FZF_CTRL_T_COMMAND|export FZF_CTRL_T_COMMAND|g' $ENVVAR_R
    sudo sed -i 's|#export FZF_CTRL_R_OPTS|export FZF_CTRL_R_OPTS|g' $ENVVAR_R
    sudo sed -i 's|#export FZF_BIND_TYPES|export FZF_BIND_TYPES|g' $ENVVAR_R
    sudo sed -i 's|#type fd &> /dev/null|type fd &> /dev/null|g' $ENVVAR_R
    sudo sed -i 's/--bind/#--bind/' $ENVVAR_R
    sudo sed -i 's/--preview-window/#--preview-window/' $ENVVAR_R
    sudo sed -i 's/--color/#--color/' $ENVVAR_R
    if type tree &> /dev/null; then
       sudo sed -i 's|#export FZF_ALT_C_OPTS=|export FZF_ALT_C_OPTS=|g' $ENVVAR_R
    fi 
elif ! sudo grep -q "export FZF_DEFAULT_COMMAND" $ENVVAR_R; then
    printf "\n# FZF\nexport FZF_DEFAULT_COMMAND=\"$fnd\"\nexport FZF_CTRL_T_COMMAND='$FZF_DEFAULT_COMMAND'" | sudo tee -a $ENVVAR_R
    if type tree &> /dev/null; then
        printf "\nexport FZF_ALT_C_OPTS=\"--preview 'tree -C {}\"" | sudo tee -a $ENVVAR_R
    fi
fi
 

#if type kitty &> /dev/null; then
#    reade -Q "GREEN" -i "y" -p "Add shortcut for fzf-autocompletion? (Ctrl-Tab) [Y/n]: " "n" comp_key
#    if [ "$comp_key" == "y" ]; then
#        if ! test -f .keybinds.d/keybinds.bash && ! grep -q "(Kitty)" ~/.fzf/shell/key-bindings.bash; then
#            printf "\n# (Kitty) Ctrl-tab for fzf autocompletion" >> ~/.fzf/shell/key-bindings.bash
#            printf "\nbind '\"\\\e[9;5u\": \" **\\\t\"'" >> ~/.fzf/shell/key-bindings.bash
#       fi
#     fi
#fi
#unset comp_key

    
if ! test -f /usr/bin/rifle || ! test -f ~/.bash_aliases.d/fzf-rifle.sh && grep -q "fzf_rifle" ~/.keybinds.d/keybinds.bash; then
    reade -Q "GREEN" -i "y" -p "Use rifle (file opener from 'ranger') to open found files and dirs with a custom Ctrl-F filesearch shortcut? [Y/n]: " "n" fzf_f
    if [ "$fzf_f" == "y" ] || [ -z "$fzf_f" ] ; then
        if ! type rifle &> /dev/null; then
            if ! type python &> /dev/null; then
                if test $distro_base == 'Debian'; then
                    eval "$pac_ins python3 python-is-python3"
                elif test $distro_base == 'Arch'; then  
                    eval "$pac_ins python"
                fi
            fi
            sudo wget -P /usr/bin/ https://raw.githubusercontent.com/ranger/ranger/master/ranger/ext/rifle.py 
            sudo mv -v /usr/bin/rifle.py /usr/bin/rifle
            sudo chmod +x /usr/bin/rifle
        fi
        if ! test -f ranger/.config/ranger/rifle.conf; then
            curl -o ~/.config/ranger/rifle.conf https://raw.githubusercontent.com/water-carrier3/dotfiles/main/ranger/.config/ranger/rifle.conf  
            curl -o ~/.bash_aliases.d/fzf-rifle.sh https://raw.githubusercontent.com/water-carrier3/dotfiles/main/fzf/.bash_aliases.d/fzf-rifle.sh
        else
            mkdir -p ~/.config/ranger
            cp -fv ranger/.config/ranger/rifle.conf ~/.config/ranger/
            cp -fv fzf/.bash_aliases.d/fzf-rifle.sh ~/.bash_aliases.d/
        fi
        sed -i 's/\\\C-f//g' ~/.fzf/shell/key-bindings.bash
        sed -i "s|\(bind -m vi-insert '\"\\\C-t\":.*\)|\1\n\n    # CTRL-F - Search with previews and other handy additions\n    bind -m emacs-standard '\"\\\C-f\": \"\\\C-t\"'\n    bind -m vi-command '\"\\\C-f\": \"\\\C-o\\\C-f\\\C-o\"'\n    bind -m vi-insert '\"\\\C-f\": \"\\\C-o\\\C-f\\\C-o\"'|g" ~/.fzf/shell/key-bindings.bash
        sed -i "s|\(bind -m vi-insert -x '\"\\\C-t\":.*\)|\1\n\n    # CTRL-F - Search with previews and other handy additions\n    bind -m emacs-standard -x '\"\\\C-f\": fzf_rifle'\n    bind -m vi-command -x '\"\\\C-f\": fzf_rifle'\n    bind -m vi-insert -x '\"\\\C-f\":  fzf_rifle'|g" ~/.fzf/shell/key-bindings.bash
    fi
fi
unset fzf_f



#reade -Q "GREEN" -i "y" -p "Add shortcut for riflesearch on Ctrl-F? (Fzf and paste in console) [Y/n]: " "n" fzf_t
#if [ "$fzf_t" == "y" ] || [ -z "$fzf_t" ] ; then 
#    #sed -i 's|# CTRL-T|# CTRL-F|g' ~/.fzf/shell/key-bindings.bash
#     
#    #sed -i 's|bind -m vi-command '\''"\\C-t": |bind -m vi-command '\''"\\C-f": |g' ~/.fzf/shell/key-bindings.bash
#    #sed -i 's|bind -m vi-insert '\''"\\C-t": |bind -m vi-insert '\''"\\C-f": |g' ~/.fzf/shell/key-bindings.bash
#    #sed -i 's|bind -m emacs-standard -x '\''"\\C-t": |bind -m emacs-standard -x '\''"\\C-f": |g' ~/.fzf/shell/key-bindings.bash
#    #sed -i 's|bind -m vi-command -x '\''"\\C-t": |bind -m vi-command -x '\''"\\C-f": |g' ~/.fzf/shell/key-bindings.bash
#    #sed -i 's|bind -m vi-insert -x '\''"\\C-t": |bind -m vi-insert -x '\''"\\C-f": |g' ~/.fzf/shell/key-bindings.bash
#fi


# reade -Q "GREEN" -i "y" -p "Change Alt-C shortcut to Ctrl-S for fzf cd? [Y/n]:" "n" fzf_t
# if [ "$fzf_t" == "y" ] || [ -z "$fzf_t" ]; then 
#     sed -i 's|# ALT-C - cd into the selected directory|# CTRL-S - cd into the selected directory|g' ~/.fzf/shell/key-bindings.bash
#     sed -i 's|\\ec|\\C-s|g'  ~/.fzf/shell/key-bindings.bash
#     #sed -i 's|bind -m emacs-standard '\''"\\ec"|bind -m emacs-standard '\''"\\es"|g'  ~/.fzf/shell/key-bindings.bash
#     #sed -i 's|bind -m vi-command '\''"\\ec"|bind -m vi-command '\''"\\es"|g' ~/.fzf/shell/key-bindings.bash
#     #sed -i 's|bind -m vi-insert  '\''"\\ec"|bind -m vi-insert  '\''"\\es"|g' ~/.fzf/shell/key-bindings.bash
# fi
#unset fzf_t;


if ! test -f ~/.bash_aliases.d/docker-fzf.sh; then
    reade -Q "GREEN" -i "y" -p "Install fzf-docker (fzf aliases for docker)? [Y/n]: " "n" fzf_d
    if [ "$fzf_d" == "y" ] || [ -z "$fzf_d" ]; then 
        if ! test -f checks/check_aliases_dir.sh; then
            eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/checks/check_aliases_dir.sh)" 
        else
            ./checks/check_aliases_dir.sh
        fi
        curl -o ~/.bash_aliases.d/docker-fzf.sh https://raw.githubusercontent.com/MartinRamm/fzf-docker/master/docker-fzf 
    fi
fi
unset fzf_t;
