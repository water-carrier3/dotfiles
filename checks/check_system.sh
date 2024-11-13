if type curl &> /dev/null && ! test -f ../aliases/.bash_aliases.d/00-rlwrap_scripts.sh; then
     eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/aliases/.bash_aliases.d/00-rlwrap_scripts.sh
)" 
else
    . aliases/.bash_aliases.d/00-rlwrap_scripts.sh
fi


#!/usr/bin/env bash
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Windows
                win_bash_shell=Cygwin;;
    MINGW*)     machine=Windows
                win_bash_shell=Git;;
    *)          machine="UNKNOWN:${unameOut}";;
esac

if test -z $TMPDIR; then
    TMPDIR=$(mktemp -d)
fi

pthdos2nix=""
if test $machine == 'Windows'; then 
    alias wget='wget.exe' 
    alias curl='curl.exe' 
   # https://stackoverflow.com/questions/13701218/windows-path-to-posix-path-conversion-in-bash 
   pthdos2unix="| sed 's/\\\/\\//g' | sed 's/://' | sed 's/^/\\//g'"
   wmic=$(wmic os get OSArchitecture | awk 'NR>1 {print}')
   if [[ $wmic =~ '64' ]]; then
       export ARCH_WIN='64'
   else
       export ARCH_WIN='32'
   fi
   if ! type winget &> /dev/null; then
       #win_ver=$(cmd /c ver)
       printf "${RED}Winget (official window package manager) not installed - can't run scripts without install programs through it${normal}\n" 
       reade -Q 'GREEN' -i 'y' -p "(Attempt to) Install winget? ${CYAN}(Windows 10 - version 1809 required at mimimum for winget)${GREEN} [Y/n]: " 'n' wngt
       if test $wngt == 'y'; then
        tmpd=$(mktemp -d)
        wget -P $tmpd https://raw.githubusercontent.com/asheroto/winget-install/master/winget-install.ps1  
        sudo pwsh $tmpd/winget-install.ps1
       else
            printf "${RED}Can't install scripts without winget${normal}\n" 
            #exit 1 
       fi
   fi
   if ! type sudo &> /dev/null; then
       printf "${RED}Sudo (Commandline tool to install/modify files at higher privilige, as root/admin) not installed - most of the script won't run without without${normal}\n" 
       reade -Q 'GREEN' -i 'y' -p 'Install (g)sudo (unofficial sudo)? [Y/n]: ' 'n' gsdn
       if test $gsdn == 'y'; then
            ./../install_gsudo.sh
       #else
           #exit 1
       fi
   fi
   if ! type jq &> /dev/null; then
       reade -Q 'GREEN' -i 'y' -p 'Install jq? (Json parser - used in scripts to get latest releases from github) [Y/n]: ' 'n' jqin 
       if test $jqin == 'y'; then
            winget install jqlang.jq
       fi
   fi
   unset wngt wmic gsdn jqin
fi


if test -z $EDITOR; then
    if type nano &> /dev/null; then
        EDITOR=nano
    elif type vi &> /dev/null; then
        EDITOR=vi
    else
        EDITOR=edit
    fi
fi

if type whereis &> /dev/null; then
    function where_cmd() { 
        eval "whereis $1 $pthdos2unix" | awk '{print $2;}'; 
    } 
elif type where &> /dev/null; then
    function where_cmd() { 
        eval "where $1 $pthdos2unix"; 
    } 
else
    printf "Can't find a 'where' command (whereis/where)\n"
    #exit 1 
fi

# https://unix.stackexchange.com/questions/202891/how-to-know-whether-wayland-or-x11-is-being-used
export X11_WAY="$(loginctl show-session $(loginctl | grep $(whoami) | awk 'NR=1{print $1}') -p Type | awk -F= 'NR==1{print $2}')"

distro_base=/
distro=/
packagemanager=/
arch=/
declare -A osInfo;
osInfo[/etc/alpine-release]=apk
osInfo[/etc/arch-release]=pacman
osInfo[/etc/fedora-release]=dnf
osInfo[/etc/debian_version]=apt
osInfo[/etc/gentoo-release]=emerge
osInfo[/etc/manjaro-release]=pamac
osInfo[/etc/redhat-release]=yum
osInfo[/etc/rpi-issue]=apt
osInfo[/etc/SuSE-release]=zypp
osInfo[/etc/SUSE-brand]=zypp

for f in ${!osInfo[@]};
do
    if [ -f $f ] && [ $f == /etc/alpine-release ] && [ $distro == / ]; then
        pac="apk"
        distro_base="BSD"
        distro="Alpine"
    elif [ -f $f ] && [ $f == /etc/manjaro-release ] && [ $distro == / ]; then
        pac="pacman"
        pac_up="sudo pacman -Su"
        pac_ins="sudo pacman -S"
        pac_search="pacman -Ss"
        pac_ls_ins="pacman -Q"
         
        AUR_pac="pamac"
        AUR_up="pamac update"
        AUR_ins="pamac install"
        AUR_search="pamac search"
        AUR_ls_ins="pamac list --installed"
         

        distro_base="Arch"
        distro="Manjaro"
          
    elif test -f /etc/issue && grep -q "Ubuntu" /etc/issue && [ $distro == / ]; then
        pac="apt"
        pac_up="sudo apt update"
        pac_ins="sudo apt install"
        pac_search="apt search"
        pac_ls_ins="apt list --installed" 

        distro_base="Debian"
        distro="Ubuntu"

        codename="$(lsb_release -a | grep --color=never 'Codename' | awk '{print $2}')"
        release="$(lsb_release -a | grep --color=never 'Release' | awk '{print $2;}')"

    elif test -f $f && [[ $f == /etc/SuSE-release || $f == /etc/SUSE-brand ]] && test "$distro" == / ; then
        if ! test -z "$(lsb_release -a | grep Leap)"; then
            pac="zypper_leap"
        else
            pac="zypper_tumble"
        fi
        distro_base="Slackware"
        distro="openSuse"
    elif [ -f $f ] && [ $f == /etc/gentoo-release ] && [ $distro == / ]; then
        pac="emerge"
        distro_base="Slackware"
        distro="Gentoo"
    elif [ -f $f ] && [ $f == /etc/fedora-release ] && [ $distro == / ]; then
        pac="dnf"
        distro_base="RedHat"
        distro="Fedora"
    elif [ -f $f ] && [ $f == /etc/nix-release ] && [ $distro == / ]; then
        pac="nix profile"
        pac_ins="nix profile install"
        distro_base="Nix"
        distro="Nix" 
    elif [ -f $f ] && [ $f == /etc/redhat-release ] && [ $distro == / ]; then
        pac="yum"
        distro_base="RedHat"
        distro="Redhat"
    elif [ -f $f ] && [ $f == /etc/arch-release ] && [ $distro == / ]; then
        pac="pacman"
        pac_up="sudo pacman -Su"
        pac_ins="sudo pacman -S"
        pac_search="pacman -Ss"
        pac_ls_ins="pacman -Q" 

        
        #
        # PACMAN WRAPPERS
        # 
        
        # Check every package manager known by archwiki 
        #
        if type pamac &> /dev/null; then

            AUR_pac="pamac"
            AUR_up="pamac update"
            AUR_ins="pamac install"
            AUR_search="pamac search"
            AUR_ls_ins="pamac list --installed"    
             
            if type curl &> /dev/null && ! test -f checks/check_pamac.sh; then
                eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/checks/check_pamac.sh)" 
            else
                . ./checks/check_pamac.sh
            fi
        elif
            type pikaur &> /dev/null; then
            AUR_pac="pikaur"
            AUR_up="pikaur -Syu"
            AUR_ins="pikaur -S"
            AUR_search="pikaur -Ss"
            AUR_ls_ins="pikaur -Q"
             
        elif type yay &> /dev/null; then

            AUR_pac="yay"
            AUR_up="yay -Syu"
            AUR_ins="yay -S"
            AUR_search="yay -Ss"
            AUR_ls_ins="yay -Q" 
             
        elif type pacaur &> /dev/null; then

            AUR_pac="pacaur"
            AUR_up="pacaur -Syu"
            AUR_ins="pacaur -S"
            AUR_search="pacaur -Ss"
            AUR_ls_ins="pacaur -Q"

        elif type aura &> /dev/null; then

            AUR_pac="aura"
            AUR_up="aura -Au"
            AUR_ins="aura -A"
            AUR_search="aura -Ss"
            AUR_ls_ins="aura -Q"
             
        elif type aurman &> /dev/null; then

            AUR_pac="aurman"
            AUR_up="aurman -Syu"
            AUR_ins="aurman -S"
            AUR_search="aurman -Ss"
            AUR_ls_ins="aurman -Q"

        elif type pakku &> /dev/null ; then

            AUR_pac="pakku"
            AUR_up="pakku -Syu"
            AUR_ins="pakku -S"
            AUR_search="pakku -Ss"
            AUR_ls_ins="pakku -Q"
             
        elif type paru &> /dev/null; then
            AUR_pac="paru"
            AUR_up="paru -Syua"
            AUR_ins="paru -S"
            AUR_search="paru -Ss"
            AUR_search="paru -Q"
             
        elif type trizen &> /dev/null; then
            AUR_pac="trizen"
            AUR_up="trizen -Syu"
            AUR_ins="trizen -S"
            AUR_search="trizen -Ss"
            AUR_ls_ins="trizen -Q"

        #
        # SEARCH AND BUILD
        # 
        
        # Aurutils
        elif type aur &> /dev/null; then
            AUR_pac="aur"
            AUR_up=""
            AUR_ins=""
            AUR_search="aur search"
             
        #elif type repoctl &> /dev/null; then
        #    pac_AUR="repoctl"
        #elif type yaah &> /dev/null; then
        #    pac_AUR="yaah"
        #elif type bauerbill &> /dev/null; then
        #    pac_AUR="bauerbill"
        #elif type PKGBUILDer &> /dev/null; then
        #    pac_AUR="PKGBUILDer"
        #elif type rua &> /dev/null; then
        #    pac_AUR="rua"
        #elif type pbget &> /dev/null; then
        #    pac_AUR="pbget"
        #elif type argon &> /dev/null ; then
        #    pac_AUR="argon"
        #elif type cylon &> /dev/null; then
        #    pac_AUR="cylon"
        #elif type kalu &> /dev/null; then
        #    pac_AUR="kalu"
        #elif type octopi &> /dev/null; then
        #    pac_AUR="octopi"
        #elif type PkgBrowser &> /dev/null; then
        #    pac_AUR="PkgBrowser"
        #elif type yup &> /dev/null ; then
        #    pac_AUR="yup"
        elif type auracle &> /dev/null; then

            AUR_pac="auracle"
            AUR_up="auracle update"
            AUR_ins=""
            AUR_search="auracle search"
             

        else
            printf "Your Arch system seems to have no (known) AUR helper installed\n"
            reade -Q "GREEN" -i "y" -p "Install pikaur ( Pacman wrapper )? [Y/n]: " "n" insyay
            if [ "y" == "$insyay" ]; then 

                if type curl &> /dev/null && ! test -f ../AUR_insers/install_pikaur.sh; then
                    eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/AUR_insers/install_pikaur.sh)" 
                else
                    eval ../AUR_insers/install_pikaur.sh
                fi

                AUR_pac="pikaur"
                AUR_up="pikaur -Syu"
                AUR_ins="pikaur -S"
                AUR_search="pikaur -Ss"
                AUR_ls_ins="pikaur -Q"
                 
            fi
            unset insyay 
        fi

        distro_base="Arch"
        distro="Arch"

    elif [ -f $f ] && [ $f == /etc/rpi-issue ] && [ $distro == / ];then

        pac="apt"
        pac_ins="sudo apt install"
        pac_up="sudo apt update"
        pac_search="apt search"
        pac_ls_ins="apt list --installed"
                     
        distro_base="Debian"
        distro="Raspbian"

    elif [ -f $f ] && [ $f == /etc/debian_version ] && [ $distro == / ];then
        pac="apt"
        pac_ins="sudo apt install"
        pac_up="sudo apt update"
        pac_search="apt search"
        pac_ls_ins="apt list --installed"
         
        distro_base="Debian"   
        distro="Debian"
    fi 
done
    

if ! type curl &> /dev/null && ! test -z "$pac_ins"; then
    printf "$(tput setaf 6 && tput bold)curl${normal} not installed (cmd tool for interacting with urls)\n$(tput sgr0)"
    reade -Q 'GREEN' -i 'y' -p "Install curl? [Y/n]: " 'n' ins_curl
    if test "$ins_curl" == 'y' || test "$ins_curl" == '' || test "$ins_curl" == 'Y'; then
       eval "$pac_ins curl"
    fi
fi
unset ins_curl

if ! type wget &> /dev/null && ! test -z "$pac_ins"; then
    printf "$(tput setaf 6 && tput bold)wget${normal} not installed (cmd tool for downloading files for the internet)\n$(tput sgr0)"
    reade -Q 'GREEN' -i 'y' -p "Install wget? [Y/n]: " 'n' ins_wget
    if test "$ins_wget" == 'y' || test "$ins_wget" == '' || test "$ins_wget" == 'Y'; then
       eval "$pac_ins wget"
    fi
fi
unset ins_wget


if type nala &> /dev/null && test $pac == 'apt'; then
    pac="nala"
    pac_ins="sudo nala install"
    pac_up="sudo nala update" 
fi

# TODO: Change this to uname -sm?
if test $machine == 'Linux'; then
    arch_cmd="lscpu"
elif test $machine == 'Mac'; then
    arch_cmd="sysctl -n machdep.cpu.brand_string"
fi

if eval "$arch_cmd" | grep -q "Intel"; then
    arch="386"
elif eval "$arch_cmd" | grep -q "AMD"; then
    if lscpu | grep -q "x86_64"; then 
        arch="amd64"
    else
        arch="amd32"
    fi
elif eval "$arch_cmd" | grep -q "armv"; then
    arch="armv7l"
elif eval "$arch_cmd" | grep -q "aarch"; then
    arch="arm64"
fi

function check-ppa(){
    SCRIPT="check-ppa"
    VERSION="1.1"
    DATE="2024-09-02"
    RELEASE="$(lsb_release -si) $(lsb_release -sr)"
    
    helpsection() 
    { 
        echo "Usage : $SCRIPT [PPA]... 
    -h, --help     shows this help

    Version $VERSION - $DATE"
    }

    ppa_verification()
    { 
        local ppa="${1#ppa:}"

        local codename="$(lsb_release -sc)"
        local url="http://ppa.launchpad.net/$ppa/ubuntu/dists/$codename/"

        wget "$url" -q -O /dev/null
        ######################################################################
        # Exit Status
        #
        # Wget may return one of several error codes if it encounters problems.
        # 0 No problems occurred.
        # 1 Generic error code.
        # 2 Parse error--for instance, when parsing command-line options, the `.wgetrc' or `.netrc'...
        # 3 File I/O error.
        # 4 Network failure.
        # 5 SSL verification failure.
        # 6 Username/password authentication failure.
        # 7 Protocol errors.
        # 8 Server issued an error response.
        ######################################################################
        case $? in
          0) # Success
            echo "'$ppa' is ${GREEN}OK${normal} for $RELEASE"
            ;;
          8) # HTTP 404 (Not Found) would result in wget returning 8
            echo "'$ppa' is ${RED}UNAVAILABLE${normal} for $RELEASE"
            return 1
            ;;
          *)
            echo "Error fetching $url" >&2
            return 3
        esac
    }

    PPA=
    while [ -n "$*" ] ; do
        case "$1" in
          -h|--help)
            helpsection
            return 0
            ;;
          *)
            PPA="$@"
            ;;
        esac
        shift
    done

    if [ -z "$PPA" ]; then
        helpsection >&2
        return 2
    fi

    ppa_verification "$PPA"
}

complete -W "-h --help" check-ppa

# VARS

export PROFILE=~/.profile

if ! [ -f ~/.profile ]; then
    touch ~/.profile
fi

if [ -f ~/.bash_profile ]; then
    export PROFILE=~/.bash_profile
fi

export ENVVAR=~/.bashrc

if [ -f ~/.environment.env ]; then
    export ENVVAR=~/.environment.env
fi

export ALIAS=~/.bashrc

if [ -f ~/.bash_aliases ]; then
    export ALIAS=~/.bash_aliases
fi

if [ -d ~/.bash_aliases.d/ ]; then
    export ALIAS_FILEDIR=~/.bash_aliases.d/
fi

export COMPLETION=~/.bashrc

if [ -f ~/.bash_completion ]; then
    export COMPLETION=~/.bash_completion
fi

if [ -d ~/.bash_completion.d/ ]; then
    export COMPLETION_FILEDIR=~/.bash_completion.d/
fi

export KEYBIND=~/.bashrc

if [ -f ~/.keybinds ]; then
    export KEYBIND=~/.keybinds
fi

if [ -d ~/.keybinds.d/ ]; then
    export KEYBIND_FILEDIR=~/.keybinds.d/
fi

if [ -f ~/.bash_profile ]; then
    export PROFILE=~/.bash_profile
fi

export PROFILE_R=/root/.profile
export ALIAS_R=/root/.bashrc
export COMPLETION_R=/root/.bashrc
export KEYBIND_R=/root/.bashrc
export ENVVAR_R=/root/.bashrc

echo "This next $(tput setaf 1)sudo$(tput sgr0) checks for the profile, environment, bash_alias, bash_completion and keybind files and dirs in '/root/' to generate global variables.";

if ! sudo test -f /root/.profile; then
    sudo touch /root/.profile
fi

if sudo test -f /root/.bash_profile; then
    export PROFILE_R=/root/.bash_profile
fi

if sudo test -f /root/.environment.env; then
    export ENVVAR_R=/root/.environment.env
fi

if sudo test -f /root/.bash_aliases; then
    export ALIAS_R=/root/.bash_aliases
fi
if sudo test -d /root/.bash_aliases.d/; then
    export ALIAS_FILEDIR_R=/root/.bash_aliases.d/
fi

if sudo test -f /root/.bash_completion; then
    export COMPLETION_R=/root/.bash_completion
fi

if sudo test -d /root/.bash_completion.d/; then
    export COMPLETION_FILEDIR_R=/root/.bash_completion.d/
fi
if sudo test -f /root/.keybinds  ; then
    export KEYBIND_R=/root/.keybinds
fi

if sudo test -d /root/.keybinds.d/  ; then
    export KEYBIND_FILEDIR_R=/root/.keybindsd.d/
fi
