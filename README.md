# workstation

From your home directory execute one of the following:

## Initial clone
```
git init
git remote add origin https://github.com/hsiliev/workstation-scripts.git
git fetch
git checkout -t origin/master

mkdir workspace

brew install direnv rbenv go nvm
brew cask install java

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
