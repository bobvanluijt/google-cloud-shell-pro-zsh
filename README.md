# ZSH for Google Cloud Shell Pro

Oh My Zsh for Google Cloud Shell Pro

### Install
1. Open Cloud Shell Pro
2. Run: `sh -c "$(curl -fsSL https://goo.gl/kXOWTl)"` (link to install script in this repo)

_Note: after 30 min the cloud shell resets to its original state, the script will automatically install after this._

### Available besides standard plugins
- `gcloud-zsh-completion - Adds completions for the Google Cloud SDK`
- `docker-zsh-completion - Adds completions for Docker`

### Remove

- `$ sudo rm -r ~/.oh-my-zsh`
- `$ sudo apt-get remove --purge zsh`
- `$ rm .zsh*`
- `$ vim ~/.bashrc` -> remove last line