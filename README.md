# Bash Script: Backup Magento2 Code + Database

This utility script helps you to backup Magento2 code and database.   
You can either run the command manually or can automate it via cronjob.


## INSTALL
Simply run the following command
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
mage2-backup.sh --help
```

### To backup database only
```
mage2-backup.sh --type=db --src-dir=/path/to/magento2/root --dest-dir=/path/to/destination
```

### To backup code only
```
mage2-backup.sh --type=code --skip-media=1 --src-dir=/path/to/magento2/root --dest-dir=/path/to/destination
```

### To backup code + database
```
mage2-backup.sh --type=all --skip-media=1 --src-dir=/path/to/magento2/root --dest-dir=/path/to/destination
```

## TO-DOS
 - S3 support
 - Option to exclude log tables
