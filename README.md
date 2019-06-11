# Bash Script: Backup Magento2 Code + Database

This utility script helps you to backup Magento2 code and database.   
You can either run the command manually or can automate it via cronjob.


## INSTALL
You can simply download the script file and give the executable permission.
```
curl -0 https://raw.githubusercontent.com/MagePsycho/magento2-db-code-backup-bash-script/master/src/mage2-db-code-backup.sh -o mage2-backup.sh
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
./mage2-backup.sh --backup-db --src-dir=/path/to/magento2/root --dest-dir=/path/to/destination
```

If you want to get rid of this message
> Using a password on the command line interface can be insecure.

You can create a `.my.cnf` file in home directory with the following config
```
[client]
host=localhost
user=[your-db-user]
password=[your-db-pass]
```
And use option `--use-mysql-config` as
```
./mage2-backup.sh --backup-db --use-mysql-config --src-dir=/path/to/magento2/root --dest-dir=/path/to/destination
```

### To backup code only
```
./mage2-backup.sh --backup-code --skip-media --src-dir=/path/to/magento2/root --dest-dir=/path/to/destination
```

### To backup code + database
```
./mage2-backup.sh --backup-db --backup-code --skip-media --src-dir=/path/to/magento2/root --dest-dir=/path/to/destination
```

### To schedule backup via Cron
If you want to schedule via Cron, just add the following line in your Crontab entry `crontab -e`
```
0 0 * * * /path/to/mage2-backup.sh --backup-db --backup-code --skip-media --src-dir=/path/to/magento2/root --dest-dir=/path/to/destination > /dev/null 2>&1
```
`0 0 * * *` expression means the command will run run at every midnight.

## Screenshots
![Mage2Backup Help](https://github.com/MagePsycho/magento2-db-code-backup-bash-script/raw/master/docs/mage2-backup-script-help-0.2.0.png "Mage2Backup Help")
1. Mage2Backup Help

![Mage2Backup in Action](https://github.com/MagePsycho/magento2-db-code-backup-bash-script/raw/master/docs/mage2-backup-script-help-0.2.0.png "Mage2Backup in Action")
2. Mage2Backup in Action

## TO-DOS
 - S3 support
 - Google Drive support
 - Option to exclude log tables
