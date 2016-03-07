# OSX-Scripts

## Installation

Open Terminal, ``` cd ~ ``` and paste one of the commands below. Command will be executed. If you want to log output for any case, add ``` 2>&1 | tee -a ~/osx_macports.log```at the end of install command. This will create a file named ```output.log``` in your ```$HOME```directory for futher review.

### Install Macports

```bash
sudo sh -c "$(curl -s -L https://git.io/v2pMc)"
```

### Install Sublime Text

```bash
curl -o i -L https://git.io/v2pDA && sh i -i && rm i
```
