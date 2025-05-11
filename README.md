# Cloudflare Dynamic DNS IP Updater
<img alt="GitHub" src="https://img.shields.io/github/license/iBreakEverything/Cloudflare-dynamic-DNS?color=black"> <img alt="GitHub last commit (branch)" src="https://img.shields.io/github/last-commit/iBreakEverything/Cloudflare-dynamic-DNS/main"> <img alt="GitHub contributors" src="https://img.shields.io/github/contributors/iBreakEverything/Cloudflare-dynamic-DNS">

This script is used to update Dynamic DNS (DDNS) service based on Cloudflare!

## Installation

```bash
wget TODO latest release
apt install jq
```

## Usage
### Manual run
```bash
chmod +x /path/to/script/cloudflare-ipv4.sh
/path/to/script/cloudflare-ipv4.sh
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
# * * * * * /bin/bash {Location of the script}
```

## Tested Environments:
TODO
~~Debian Bullseye 11 (Linux kernel: 6.1.28 | aarch64) <br />~~

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://github.com/K0p1-Git/cloudflare-ddns-updater/blob/main/LICENSE)
