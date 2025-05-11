# Cloudflare Dynamic DNS IP Updater
<img alt="GitHub" src="https://img.shields.io/github/license/iBreakEverything/Cloudflare-dynamic-DNS?color=black"> <img alt="GitHub last commit (branch)" src="https://img.shields.io/github/last-commit/iBreakEverything/Cloudflare-dynamic-DNS/main"> <img alt="GitHub contributors" src="https://img.shields.io/github/contributors/iBreakEverything/Cloudflare-dynamic-DNS">

This script is used to update Dynamic DNS (DDNS) service based on Cloudflare!

## Installation

```bash
# Change <SCOPE> to user or crontab and <SHELL> to bash or sh
wget https://github.com/iBreakEverything/Cloudflare-dynamic-DNS/releases/latest/download/cloudflare-<SCOPE>-<SHELL>-ipv4.sh
wget https://github.com/iBreakEverything/Cloudflare-dynamic-DNS/releases/latest/download/cloudflare-ddns.conf
apt install jq
```

## Usage
### Manual run
```bash
/path/to/script/cloudflare-user-bash-ipv4.sh
```

### Crontab
This script is used with crontab. Specify the frequency of execution through crontab.

```bash
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday 7 is also Sunday on some systems)
# │ │ │ │ │ ┌───────────── command to issue                               
# │ │ │ │ │ │
# │ │ │ │ │ │
# * * * * * /bin/bash /path/to/script/cloudflare-crontab-bash-ipv4.sh
```

## Tested Environments:
Ubuntu 24.04 (Linux 6.8.0 | x86-64)\
WSL Ubuntu 24.04 (Linux 5.15.167 | x86-64)\
Debian bookworm 12 (Linux kernel: 6.12.20 | arm64)\

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://github.com/K0p1-Git/cloudflare-ddns-updater/blob/main/LICENSE)
