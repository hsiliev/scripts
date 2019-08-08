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

# Run the setup script
./setup
```

## Subsequent clones
```
git init
git remote add origin https://github.com/hsiliev/workstation-scripts.git
git fetch
git reset origin/master
git checkout -t origin/master
```
