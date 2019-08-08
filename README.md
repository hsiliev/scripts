# workstation

From your home directory execute one of the following:

## Initial clone
```
# Setup this repo
git init
git remote add origin https://github.com/hsiliev/workstation-scripts.git
git fetch
git checkout -t origin/master
mkdir workspace

# Install bash-it
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it

# Install dependencies
brew install direnv rbenv go nvm kubectl
brew cask install adoptopenjdk

# Setup kernel limits. Needs restart
echo kern.maxfiles=65536 | sudo tee -a /etc/sysctl.conf
echo kern.maxfilesperproc=2048 | sudo tee -a /etc/sysctl.conf
sudo sysctl -w kern.maxfiles=65536
sudo sysctl -w kern.maxfilesperproc=2048
```

## Subsequent clones
```
git init
git remote add origin https://github.com/hsiliev/workstation-scripts.git
git fetch
git reset origin/master
git checkout -t origin/master
```
