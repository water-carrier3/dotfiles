#!/bin/bash

#https://bbs.archlinux.org/viewtopic.php?id=271850
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

if [ "$distro" == "Manjaro" ]; then
    eval "$pac_ins pipewire pipewire-jack wireplumber pipewire-pulse manjaro-pipewire"
elif [ "$distro_base" == "Arch" ]; then
    eval "$pac_ins pipewire pipewire-jack wireplumber pipewire-pulse"
elif [ "$distro_base" == "Debian" ]; then
    eval "$pac_ins pipewire pipewire-jack wireplumber pipewire-pulse"
fi 

if ! test -f ~/.bash_completion.d/pipewire; then
 
    reade -Q 'GREEN' -i 'y' -p "Install pipewire completions (pw-cli, wpctl)? [Y/n]: " 'n' comps
    if test $comps == 'y'; then

        if ! test -f checks/check_completions_dir.sh; then
             eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_completions_dir.sh)" 
        else
            . ./checks/check_completions_dir.sh
        fi
         
        pipewire_cmp=pipewire/.bash_completion.d/pipewire
        if ! test -f pipewire/.bash_completion.d/pipewire; then
            tmp1=$(mktemp) && curl -o $tmp https://raw.githubusercontent.com/water-carrier3/dotfiles/main/pipewire/.bash_completion.d/pipewire 
            pipewire_cmp=$tmp1
        fi

        cp -fv $pipewire_cmp ~/.bash_completion.d/ 

    fi
fi

mkdir -p ~/.config/wireplumber/wireplumber.conf.d/

if echo $(wpctl status) | grep -q 'HMDI'; then
    reade -Q 'GREEN' -i 'y' -p "Unlist all HDMI audio devices from pipewire? [Y/n]: " 'n' unlst_hdmi
    if test "$unlst_hdmi" == 'y'; then
        hdmi_f="$HOME/.config/wireplumber/wireplumber.conf.d/51-HDMI-disable.conf"  
        touch hdmi_f 
        printf "monitor.alsa.rules = [
  {
    matches = [
    ] 
    actions = {
      update-props = {
         device.disabled = true
      }
    }
  }
]" > $hdmi_f 
        hmis=$(pw-cli info all 2> /dev/null | grep --color=never hdmi | grep node.name | sed 's|.*"alsa_output\(.*\)|alsa_card\1|g' | sed 's|\(.*\)\.hdmi.*|\1|')         
        for i in $hmis; do 
            sed -i 's|\(matches = \[\)|\1\n\t{\n\t  device.name = "'"$i"'"\n\t}|g' $hdmi_f ;         
        done
    fi
fi

# https://wiki.archlinux.org/title/PipeWire#Sound_does_not_automatically_switch_when_connecting_a_new_device
if type systemctl &> /dev/null && ! test -f /etc/systemd/user/pipewire-load-switch-on-connect.service; then
    #printf "${CYAN}You should test first whether sounds autoswitches when connected${normal}\n"
    reade -Q 'GREEN' -i 'y' -p "Create 'USB-audiodevice-autoswitch-on-connect' configuration file? [Y/n]: " 'n' auto_s
    if test $auto_s == 'y'; then
        mkdir -p ~/.config/pipewire/pipewire-pulse.conf.d/
        conf=~/.config/pipewire/pipewire-pulse.conf.d/switch-on-connect.conf
        if [ ! -e $conf ] || ! grep -q "# override for pipewire-pulse.conf file" $conf; then
            echo "# override for pipewire-pulse.conf file" >> $conf
            echo "pulse.cmd = [" >> $conf
            echo "  { cmd = \"load-module\" args = \"module-always-sink\" flags = [ ] }" >> $conf
            echo "  { cmd = \"load-module\" args = \"module-switch-on-connect\" }" >> $conf
            echo "]" >> $conf
        fi
        systemctl restart --user pipewire-pulse.service 
        if systemctl status --user --no-pager -l pipewire-pulse.service | grep -q 'File exists'; then
            sed -i '/module-always-sink/d' $conf 
            systemctl restart --user pipewire-pulse.service 
        fi
        printf "${GREEN}Added pipewire conf for $USER at:\n${CYAN}$HOME/.config/pipewire/pipewire-pulse.conf.d\n${normal}" 

    #    reade -Q 'GREEN' -i 'y' -p "Install USB-audio autoswitch on connect for pipewire system-wide? (at /etc/pipewire/pipewire-pulse.conf.d/) [Y/n]: " 'n' auto_s_sys
    #    if test $auto_s_sys == 'y'; then
    #        if ! test -d /etc/pipewire/pipewire-pulse.conf.d/; then
    #            echo "Next $(tput setaf 1)sudo$(tput sgr0) will check for and create /etc/pipewire/pipewire-pulse.conf.d/"
    #            sudo mkdir -p /etc/pipewire/pipewire-pulse.conf.d/
    #        fi
    #        echo "Next $(tput setaf 1)sudo$(tput sgr0) will move $conf to /etc/pipewire/pipewire-pulse.conf.d/"
    #        sudo cp -vf $conf /etc/pipewire/pipewire-pulse.conf.d
    #        printf "${GREEN}Added pipewire conf for all users at:\n${CYAN}/etc/pipewire/pipewire-pulse.conf.d\n${normal}" 
    #    fi

    #    echo "${green}Installing systemd service${normal}" 
    #    mkdir -p ~/.config/systemd/user/
    #    serv="pipewire-load-switch-on-connect"
    #    servF="$serv.service"
    #    myuser="$USER"
    #    servFile=/etc/systemd/user/$serv.service;
    #    touch $servF
    #    echo "[Unit]" >> $servF;
    #    echo "Description=$serv service." >> $servF;

    #    echo "[Service]" >> $servF;
    #    echo "ExecStart=sudo -u $myuser env XDG_RUNTIME_DIR=/run/user/$(id -u $myuser) /usr/bin/pactl load-module module-switch-on-connect" >> $servF;

    #    echo "[Install]" >> $servF;
    #    echo "WantedBy=default.target" >> $servF;

    #    sudo mv -f $servF $servFile
    #    systemctl --user enable --now $servFile

    #    #if ! sudo grep -q "load-module module-switch-on-connect" /etc/pulse/default.pa; then
    #    #    sudo sed -i "s,\(load-module module-switch-on-port-available\),\1\nload-module module-switch-on-connect,g" /etc/pulse/default.pa
    #    #fi
    #    #printf "Added pipewire conf at:\n~/.config/pipewire/pipewire-pulse.conf.d\n/etc/pipewire/pipewire.conf.d/\n$servFile\n"
    #    #printf "Added pipewire conf at: \n~/.config/pipewire/pipewire-pulse.conf.d\n /etc/pipewire/pipewire.conf.d/\n $servFile\n /etc/pulse/default.pa\n"
    fi 
fi

if ! test -f $HOME/.config/wireplumber/wireplumber.conf.d/51-dualshock4-disable.conf; then
    mkdir -p ~/.config/wireplumber/wireplumber.conf.d/
    reade -Q 'GREEN' -i 'y' -p "Unlist dualshock 4 audio sources from pipewire? (prevents usb-autoconnect from triggering) [Y/n]: " 'n' ds4
    if [ -z $ds4 ] || [ "y" == $ds4 ] || [ "y" == $ds4 ]; then
        touch $HOME/.config/wireplumber/wireplumber.conf.d/51-dualshock4-disable.conf   
        printf "monitor.alsa.rules = [
  {
    matches = [
      { 
        device.name = \"~alsa_card.usb-Sony_Interactive_Entertainment_Wireless_Controller-*\" 
      }
    ] 
    actions = {
      update-props = {
         device.disabled = true
      }
    }
  }
]" > $HOME/.config/wireplumber/wireplumber.conf.d/51-dualshock4-disable.conf
    fi
fi

if ! test -f $HOME/.config/wireplumber/wireplumber.conf.d/51-disable-suspension.conf; then
    printf "${yellow}Noticeable audio delay or audible pop/crack when starting playback can be caused by ${YELLOW}'node suspension when inactive'${normal}\n"
    reade -Q 'GREEN' -i 'n' -p "Disable node suspension when inactive? [N/y]: " 'n' dis_node
    if test $dis_node == 'y'; then
        dis_node_f="$HOME/.config/wireplumber/wireplumber.conf.d/51-disable-suspension.conf"  
        touch dis_node_f 
        printf "monitor.alsa.rules = [
  {
    matches = [
      {
        # Matches all sources
        node.name = \"~alsa_input.*\"
      },
      {
        # Matches all sinks
        node.name = \"~alsa_output.*\"
      }
    ]
    actions = {
      update-props = {
        session.suspend-timeout-seconds = 0
      }
    }
  }
]
# bluetooth devices
monitor.bluez.rules = [
  {
    matches = [
      {
        # Matches all sources
        node.name = \"~bluez_input.*\"
      },
      {
        # Matches all sinks
        node.name = \"~bluez_output.*\"
      }
    ]
    actions = {
      update-props = {
        session.suspend-timeout-seconds = 0
      }
    }
  }
]" > $dis_node_f 
    fi 
fi


if ! type qwpgraph &> /dev/null; then
    reade -Q 'GREEN' -i 'y' -p "Install patchbay interface 'qpwgraph'? (create and manage audiostreams) [Y/n]: " 'n' patchb
    if test "$patchb" == 'y'; then
        if test "$distro_base" == 'Arch' || test "$distro_base" == 'Debian'; then
            eval "$pac_ins qpwgraph"
        fi
    fi
    unset patchb 
fi

file=pipewire/.bash_aliases.d/pipewire.sh
file1=pipewire/.bash_completions.d/pipewire
if ! test -f $file || ! test -f $file1; then
    tmp=$(mktemp) && curl -o $tmp https://raw.githubusercontent.com/water-carrier3/dotfiles/main/pipewire/.bash_aliases.d/pipewire.sh
    tmp1=$(mktemp) && curl -o $tmp1 https://raw.githubusercontent.com/water-carrier3/dotfiles/main/pipewire/.bash_completions.d/pipewire
    file=$tmp
    file1=$tmp1
fi

pipewire_r(){ 
    sudo cp -fv $file /root/.bash_aliases.d/; 
    sudo cp -fv $file1 /root/.bash_completion.d/; 
}

pipewiresh(){
    cp -fv $file ~/.bash_aliases.d/;
    cp -fv $file1 ~/.bash_completion.d/;
    yes_edit_no pipewire_r "$file $file1" "Install pipewire aliases at /root/.bash_aliases.d/ (and completions at ~/.bash_completion.d/)? " "yes" "GREEN"
}
yes_edit_no pipewiresh "$file $file1" "Install pipewire aliases at ~/.bash_aliases.d/ (and completions at ~/.bash_completion.d/)? " "yes" "GREEN"


if type systemctl &> /dev/null; then
    reade -Q 'GREEN' -i 'y' -p 'Restart pipewire service(s)? [Y/n]: ' 'n' rs_pwr
    if test "$rs_pwr" == 'y'; then
       systemctl restart --user wireplumber pipewire pipewire-pulse 
       systemctl status --user wireplumber pipewire pipewire-pulse 
    fi
fi
