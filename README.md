# OSX-Scripts

## Installation

Open Terminal, ``` cd ~ ``` and paste the commands below. Commands will execute the chosen script and save the result the file in your home directory.

### Install Macports

```bash
sudo sh -c "$(curl -s -L https://git.io/v2pMc)" 2>&1 | tee -a ~/osx_macports.log
```

### Install Sublime Text

```bash
curl -o i -L https://git.io/v2pDA && sh i -i && rm i
```
