#!/bin/bash


DOTFILES="$HOME/.dotfiles"
NAME="Eduardo Ruiz"
EMAIL="eduarbo@gmail.com"

cd ${DOTFILES}
source ./lib/utils

update_submodules() {
  e_header "Updating Submodules..."
  git pull
  git submodule update --init
}

link() {
  # Force create/replace the symlink.
  ln -fs ${DOTFILES}/${1} ${HOME}/${2}
}

mirrorfiles() {
  # Copy `.gitconfig`.
  # Any global git commands in `~/.bash_profile.local` will be written to
  # `.gitconfig`. This prevents them being committed to the repository.
  rsync -avz --quiet ${DOTFILES}/git/gitconfig  ${HOME}/.gitconfig

  # Force remove the vim directory if it's already there.
  if [ -e "${HOME}/.vim" ] ; then
    rm -rf "${HOME}/.vim"
  fi

  mkdir -p ~/bin

  # Create the necessary symbolic links between the `.dotfiles` and `HOME`
  # directory. The `bash_profile` sources other files directly from the
  # `.dotfiles` repository.
  link "zsh/zshrc"          ".zshrc"
  link "zsh/zsh_profile"    ".zsh_profile"
  link "git/gitattributes"  ".gitattributes"
  link "git/gitignore"      ".gitignore"
  link "vim"                ".vim"
  link "vim/vimrc"          ".vimrc"
  link "vim/.gvimrc"        ".gvimrc"
  link "jshintrc"           ".jshintrc"
  link "tmux.conf"          ".tmux.conf"
  link "bin/*"              "bin/"

  #Copy fonts to Fonts directory
  rsync -avz --quiet ${DOTFILES}/fonts/*  ${HOME}/Library/Fonts

  e_success "Dotfiles update complete!"
}

# Verify that the user wants to proceed before potentially overwriting files
echo
e_warning "Warning: This may overwrite your existing dotfiles."
read -p "Continue? (y/n) " -n 1
echo

if [[ $REPLY =~ ^[Yy]$ ]] ; then
  mirrorfiles
  source ${HOME}/.bash_profile
  update_submodules

  # Install Homebrew formulae 
  ./brewbootstrap
  # Install Node packages
  ./npmbootstrap
else
  echo "Aborting..."
  exit 1
fi

read -p "Are you Eduardo Ruiz (y/n) " -n 1

echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  git config --global user.email "$EMAIL"
  git config --global user.name "$NAME"
else
  e_header "Let's configure your gitconfig "
  read -p "Give your name please: "
  git config --global user.name "$REPLY"

  read -p "Now, give your email please: "
  git config --global user.email "$REPLY"
fi

e_success "AWESOME! We have finished it. Enjoy! ಠ‿ಠ "
