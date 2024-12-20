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


if ! type lowfi &> /dev/null; then
    if ! type npm &> /dev/null; then
       if ! test -f install_npm.sh; then
           eval "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/install_npm.sh)" 
       else
           ./install_npm.sh 
       fi 
    else 
        sudo npm -g update 
    fi
    sudo npm install -g lowfi 
fi
