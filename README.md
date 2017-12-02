# Bash Script: Backup Magento2 Code + Database

This utility script helps you to backup Magento2 code and database.   
You can either run the command manually or can automate it via cronjob.


## INSTALL
You can simply download the script file and give the executable permission.
```
curl -O mage2-backup.sh https://raw.githubusercontent.com/MagePsycho/magento2-db-code-backup-bash-script/master/src/mage2-db-code-backup.sh
chmod +x mage2-backup.sh
```

To make it system wide command
```
sudo mv mage2-backup.sh /usr/local/bin/mage2-backup.sh
```

## USAGE
### To display help
```
./mage2-backup.sh --help
```

### To backup database only
```
./mage2-backup.sh --type=db --src-dir=/path/to/magento2/root --dest-dir=/path/to/destination
```

### To backup code only
```
./mage2-backup.sh --type=code --skip-media=1 --src-dir=/path/to/magento2/root --dest-dir=/path/to/destination
```

### To backup code + database
```
./mage2-backup.sh --type=all --skip-media=1 --src-dir=/path/to/magento2/root --dest-dir=/path/to/destination
```

### To schedule backup via Cron
If you want to schedule via Cron, just add the following line in your Crontab entry `crontab -e`
```
0 0 * * * /path/to/mage2-backup.sh --type=all --skip-media=1 --src-dir=/path/to/magento2/root --dest-dir=/path/to/destination > /dev/null 2>&1
```
`0 0 * * *` expression means the command will run run at every midnight.

## Screenshots
![Mage2Backup Help](https://github.com/MagePsycho/magento2-db-code-backup-bash-script/raw/master/docs/mage2-backup-script-help.png "Mage2Backup Help")
1. Screentshot - Mage2Backup Help

## TO-DOS
 - S3 support
 - Google Drive support
 - Option to exclude log tables
