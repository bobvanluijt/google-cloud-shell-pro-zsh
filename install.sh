##
# This is an adoption from Oh My Zsh for Google Cloud Shell
##

main() {

  # Install zsh
  sudo apt-get -qq update 
  sudo apt-get -qq install zsh -y

  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if which tput >/dev/null 2>&1; then
      ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi

  # Only enable exit-on-error after the non-critical colorization stuff,
  # which may fail on systems lacking tput or terminfo
  set -e

  CHECK_ZSH_INSTALLED=$(grep /zsh$ /etc/shells | wc -l)
  if [ ! $CHECK_ZSH_INSTALLED -ge 1 ]; then
    printf "${YELLOW}Zsh is not installed!${NORMAL} Please install zsh first!\n"
    exit
  fi
  unset CHECK_ZSH_INSTALLED

  if [ ! -n "$ZSH" ]; then
    ZSH=~/.oh-my-zsh
  fi

  if [ -d "$ZSH" ]; then
    printf "${YELLOW}You already have Oh My Zsh installed.${NORMAL}\n"
    printf "You'll need to remove $ZSH if you want to re-install.\n"
    exit
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  printf "${BLUE}Cloning Oh My Zsh...${NORMAL}\n"
  hash git >/dev/null 2>&1 || {
    echo "Error: git is not installed"
    exit 1
  }
  # The Windows (MSYS) Git is not compatible with normal use on cygwin
  if [ "$OSTYPE" = cygwin ]; then
    if git --version | grep msysgit > /dev/null; then
      echo "Error: Windows/MSYS Git is not supported on Cygwin"
      echo "Error: Make sure the Cygwin git package is installed and is first on the path"
      exit 1
    fi
  fi
  env git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $ZSH || {
    printf "Error: git clone of oh-my-zsh repo failed\n"
    exit 1
  }

  printf "${BLUE}Looking for an existing zsh config...${NORMAL}\n"
  if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
    printf "${YELLOW}Found ~/.zshrc.${NORMAL} ${GREEN}Backing up to ~/.zshrc.pre-oh-my-zsh${NORMAL}\n";
    mv ~/.zshrc ~/.zshrc.pre-oh-my-zsh;
  fi

  printf "${BLUE}Using the Oh My Zsh template file and adding it to ~/.zshrc${NORMAL}\n"
  cp $ZSH/templates/zshrc.zsh-template ~/.zshrc
  sed "/^export ZSH=/ c\\
  export ZSH=$ZSH
  " ~/.zshrc > ~/.zshrc-omztemp
  mv -f ~/.zshrc-omztemp ~/.zshrc

  # If this user's login shell is not already "zsh", attempt to switch.
  TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
  if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
    # If this platform provides a "chsh" command (not Cygwin), do it, man!
    if hash chsh >/dev/null 2>&1; then
      printf "${BLUE}Time to change your default shell to zsh!${NORMAL}\n"
      echo 'if ! dpkg-query -l zsh > /dev/null; then'
      echo '    sudo rm -r ~/.oh-my-zsh'
      echo '    sudo rm .zsh*'
      echo '    sh -c "$(curl -fsSL https://raw.githubusercontent.com/bobvanluijt/google-cloud-shell-pro-zsh/master/install.sh)"'
      echo 'fi'
      echo '$(grep /zsh$ /etc/shells | tail -1)' >> ~/.bashrc
    # Else, suggest the user do so manually.
    else
      printf "I can't change your shell automatically because this system does not have chsh.\n"
      printf "${BLUE}Please manually change your default shell to zsh!${NORMAL}\n"
    fi
  fi

  ##
  # Install gcloud plugin
  ##
  cd ~/.oh-my-zsh/plugins
  git clone https://github.com/littleq0903/gcloud-zsh-completion.git
  echo "fpath=(~/.oh-my-zsh/plugins/gcloud-zsh-completion/src ~/.oh-my-zsh/plugins/docker-compose ~/.oh-my-zsh/plugins/docker ~/.oh-my-zsh/plugins/git ~/.oh-my-zsh/functions ~/.oh-my-zsh/completions /usr/local/share/zsh/site-functions /usr/share/zsh/vendor-functions /usr/share/zsh/vendor-completions /usr/share/zsh/functions/Calendar /usr/share/zsh/functions/Chpwd /usr/share/zsh/functions/Completion /usr/share/zsh/functions/Completion/AIX /usr/share/zsh/functions/Completion/BSD /usr/share/zsh/functions/Completion/Base /usr/share/zsh/functions/Completion/Cygwin /usr/share/zsh/functions/Completion/Darwin /usr/share/zsh/functions/Completion/Debian /usr/share/zsh/functions/Completion/Linux /usr/share/zsh/functions/Completion/Mandriva /usr/share/zsh/functions/Completion/Redhat /usr/share/zsh/functions/Completion/Solaris /usr/share/zsh/functions/Completion/Unix /usr/share/zsh/functions/Completion/X /usr/share/zsh/functions/Completion/Zsh /usr/share/zsh/functions/Completion/openSUSE /usr/share/zsh/functions/Exceptions /usr/share/zsh/functions/MIME /usr/share/zsh/functions/Misc /usr/share/zsh/functions/Newuser /usr/share/zsh/functions/Prompts /usr/share/zsh/functions/TCP /usr/share/zsh/functions/VCS_Info /usr/share/zsh/functions/VCS_Info/Backends /usr/share/zsh/functions/Zftp /usr/share/zsh/functions/Zle)" >> ~/.zshrc
  echo "autoload -U compinit compdef" >> ~/.zshrc
  echo "compinit" >> ~/.zshrc
  echo "cd ~" >> ~/.zshrc

  ##
  # Fancy Ascii
  ##
  echo "clear" >> ~/.zshrc
  echo "echo '   _____ _                 _    _____ _          _ _   _____           '" >> ~/.zshrc
  echo "echo '  / ____| |               | |  / ____| |        | | | |  __ \          '" >> ~/.zshrc
  echo "echo ' | |    | | ___  _   _  __| | | (___ | |__   ___| | | | |__) | __ ___  '" >> ~/.zshrc
  echo "echo ' | |    | |/ _ \| | | |/ _  |  \___ \|  _ \ / _ \ | | |  ___/  __/ _ \ '" >> ~/.zshrc
  echo "echo ' | |____| | (_) | |_| | (_| |  ____) | | | |  __/ | | | |   | | | (_) |'" >> ~/.zshrc
  echo "echo '  \_____|_|\___/ \__,_|\__,_| |_____/|_| |_|\___|_|_| |_|   |_|  \___/ '" >> ~/.zshrc
  echo "echo ' '" >> ~/.zshrc
  echo "echo ' - Type help for help'" >> ~/.zshrc
  echo "echo ' - Autocomplete for gcloud tool is enabled'" >> ~/.zshrc

  $(grep /zsh$ /etc/shells | tail -1)

}

main