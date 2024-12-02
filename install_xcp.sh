if ! test -f install_cargo.sh; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/water-carrier3/dotfiles/main/install_cargo.sh)"
else
   ./install_cargo.sh
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

cargo install xcp