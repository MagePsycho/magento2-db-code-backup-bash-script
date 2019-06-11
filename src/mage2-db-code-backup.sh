#!/bin/bash

#
# Script to backup Magento2 Codebase + Database
#
# @author   Raj KB <magepsycho@gmail.com>
# @website  http://www.magepsycho.com
# @version  0.2.0

# UnComment it if bash is lower than 4.x version
shopt -s extglob

################################################################################
# CORE FUNCTIONS - Do not edit
################################################################################
#
# VARIABLES
#
_bold=$(tput bold)
_underline=$(tput sgr 0 1)
_reset=$(tput sgr0)

_purple=$(tput setaf 171)
_red=$(tput setaf 1)
_green=$(tput setaf 76)
_tan=$(tput setaf 3)
_blue=$(tput setaf 38)

#
# HEADERS & LOGGING
#
function _debug()
{
    if [[ "$DEBUG" = 1 ]]; then
        "$@"
    fi
}

function _header()
{
    printf '\n%s%s==========  %s  ==========%s\n' "$_bold" "$_purple" "$@" "$_reset"
}

function _arrow()
{
    printf '➜ %s\n' "$@"
}

function _success()
{
    printf '%s✔ %s%s\n' "$_green" "$@" "$_reset"
}

function _error() {
    printf '%s✖ %s%s\n' "$_red" "$@" "$_reset"
}

function _warning()
{
    printf '%s➜ %s%s\n' "$_tan" "$@" "$_reset"
}

function _underline()
{
    printf '%s%s%s%s\n' "$_underline" "$_bold" "$@" "$_reset"
}

function _bold()
{
    printf '%s%s%s\n' "$_bold" "$@" "$_reset"
}

function _note()
{
    printf '%s%s%sNote:%s %s%s%s\n' "$_underline" "$_bold" "$_blue" "$_reset" "$_blue" "$@" "$_reset"
}

function _die()
{
    _error "$@"
    exit 1
}

function _safeExit()
{
    exit 0
}

#
# UTILITY HELPER
#
function _seekConfirmation()
{
  printf '\n%s%s%s' "$_bold" "$@" "$_reset"
  read -p " (y/n) " -n 1
  printf '\n'
}

# Test whether the result of an 'ask' is a confirmation
function _isConfirmed()
{
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        return 0
    fi
    return 1
}


function _typeExists()
{
    if type "$1" >/dev/null; then
        return 0
    fi
    return 1
}

function _isOs()
{
    if [[ "${OSTYPE}" == $1* ]]; then
      return 0
    fi
    return 1
}

function _checkRootUser()
{
    #if [ "$(id -u)" != "0" ]; then
    if [ "$(whoami)" != 'root' ]; then
        echo "You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
    fi

}

function _printPoweredBy()
{
    local mp_ascii
    mp_ascii='
   __  ___              ___               __
  /  |/  /__ ____ ____ / _ \___ __ ______/ /  ___
 / /|_/ / _ `/ _ `/ -_) ___(_-</ // / __/ _ \/ _ \
/_/  /_/\_,_/\_, /\__/_/  /___/\_, /\__/_//_/\___/
            /___/             /___/
'
    cat <<EOF
${_green}
Powered By:
$mp_ascii

 >> Store: ${_reset}${_underline}${_blue}http://www.magepsycho.com${_reset}${_reset}${_green}
 >> Blog:  ${_reset}${_underline}${_blue}http://www.blog.magepsycho.com${_reset}${_reset}${_green}

################################################################
${_reset}
EOF
}

################################################################################
# SCRIPT FUNCTIONS
################################################################################
function _printUsage()
{
    echo -n "$(basename "$0") [OPTION]...

Backup Magento2 Codebase + Database.
Version $VERSION

    Options:
        -sd,    --src-dir          Source directory (from where backup file will be created)
        -dd,    --dest-dir         Destination directory (to where the backup file will be moved)
        -bd,	--backup-db		   Backup DB
		-bc,	--backup-code	   Backup Code
        -uc,	--use-mysql-config Use MySQL config file (~/.my.cnf)
        -sm,    --skip-media       Skip media folder from code backup
        -h,     --help             Display this help and exit
        -v,     --version          Output version information and exit

    Examples:
        $(basename "$0") --backup-db --backup-code --skip-media --src-dir=... --dest-dir=...

"
    _printPoweredBy
    exit 1
}

function processArgs()
{
    # Parse Arguments
    for arg in "$@"
    do
        case $arg in
            -bd=*|--backup-db)
                M2_BACKUP_DB=1
            ;;
            -bc=*|--backup-code)
                M2_BACKUP_CODE=1
            ;;
            -sd=*|--src-dir=*)
                M2_SRC_DIR="${arg#*=}"
            ;;
            -dd=*|--dest-dir=*)
                M2_DEST_DIR="${arg#*=}"
            ;;
            -uc|--use-mysql-config)
                M2_USE_MYSQL_CONFIG=1
            ;;
            -sm|--skip-media)
                M2_SKIP_MEDIA=1
            ;;
            -bn=*|--backup-name=*)
                M2_BACKUP_NAME="${arg#*=}"
            ;;
            --debug)
                DEBUG=1
            ;;
            -h|--help)
                _printUsage
            ;;
            *)
                _printUsage
            ;;
        esac
    done

    validateArgs
    sanitizeArgs
}

function validateArgs()
{
    ERROR_COUNT=0
    if [[ -z "$M2_BACKUP_DB" && -z "$M2_BACKUP_CODE" ]]; then
        _error "You should mention at least one of the backup types: --backup-db or --backup-code"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    if [[ -z "$M2_SRC_DIR" ]]; then
        _error "Source directory parameter missing."
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    if [[ ! -z "$M2_SRC_DIR" && ! -f "$M2_SRC_DIR/app/etc/env.php" ]]; then
        _error "Source directory must be Magento 2 root folder."
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    if [[ -z "$M2_DEST_DIR" ]]; then
        _error "Destination directory parameter missing."
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    if [[ ! -z "$M2_DEST_DIR" ]] && ! mkdir -p "$M2_DEST_DIR"; then
        _error "Unable to create destination directory."
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    #echo "$ERROR_COUNT"
    [[ "$ERROR_COUNT" -gt 0 ]] && exit 1
}

function sanitizeArgs()
{
    # remove trailing /
    if [[ ! -z "$M2_SRC_DIR" ]]; then
        M2_SRC_DIR="${M2_SRC_DIR%/}"
    fi

    if [[ ! -z "$M2_DEST_DIR" ]]; then
        M2_DEST_DIR="${M2_DEST_DIR%/}"
    fi
}

function prepareBackupName()
{
    if [[ -z "$M2_BACKUP_NAME" ]]; then
        #MD5=`echo \`date\` $RANDOM | md5sum | cut -d ' ' -f 1`
        DATETIME=$(date +"%Y-%m-%d-%H-%M-%S")
        M2_BACKUP_NAME="mage2-backup.$DATETIME"
    fi
}

function prepareCodebaseFilename()
{
    M2_CODE_BACKUP_FILE="${M2_DEST_DIR}/${M2_BACKUP_NAME}.tar.gz"
}

function prepareDatabaseFilename()
{
    M2_DB_BACKUP_FILE="${M2_DEST_DIR}/${M2_BACKUP_NAME}.sql.gz"
}

function createDbBackup()
{
    _success "Dumping MySQL..."
    local host username password dbName
    # TODO FIX if there are multiple occurences
    host=$(grep host "${M2_SRC_DIR}/app/etc/env.php" | cut -d "'" -f 4)
    username=$(grep username "${M2_SRC_DIR}/app/etc/env.php" | cut -d "'" -f 4)
    password=$(grep password "${M2_SRC_DIR}/app/etc/env.php" | cut -d "'" -f 4)
    dbName=$(grep dbname "${M2_SRC_DIR}/app/etc/env.php" |cut -d "'" -f 4)

    # @todo option to skip log tables
	if [[ "$M2_USE_MYSQL_CONFIG" -eq 1 ]]; then
		mysqldump "$dbName" | gzip > "$M2_DB_BACKUP_FILE"
	else
		mysqldump -h "$host" -u "$username" -p"$password" "$dbName" | gzip > "$M2_DB_BACKUP_FILE"
	fi
	_success "Done!"
}

function createCodeBackup()
{
    _success "Archiving Codebase..."

    declare -a EXC_PATH
    EXC_PATH[1]=./.git
    EXC_PATH[2]=./var
    EXC_PATH[3]=./pub/static
    EXC_PATH[4]=./app/etc/env.php

    if [[ "$M2_SKIP_MEDIA" == 1 ]]; then
        EXC_PATH[5]=./pub/media
    fi

    EXCLUDES=''
    for i in "${!EXC_PATH[@]}" ; do
        CURRENT_EXC_PATH=${EXC_PATH[$i]}
        # note the trailing space
        EXCLUDES="${EXCLUDES}--exclude=${CURRENT_EXC_PATH} "
    done

    tar -zcf "$WP_CODE_BACKUP_FILE" ${EXCLUDES} -C "${WP_SRC_DIR}"

    if [[ "$M2_SKIP_MEDIA" == 1 ]]; then
		tar -zcf "$M2_CODE_BACKUP_FILE" --exclude="./var" --exclude="./pub/media" --exclude="./pub/static" -C "${M2_SRC_DIR}" .
	else
		tar -zcf "$M2_CODE_BACKUP_FILE" --exclude="./var" --exclude="./pub/static" -C "${M2_SRC_DIR}" .
	fi
	_success "Done!"
}

function printSuccessMessage()
{
    _success "Magento2 Backup Completed!"

    echo "################################################################"
    echo ""
    echo " >> Backup Type           : ${M2_BACKUP_TYPE}"
    echo " >> Backup Source         : ${M2_SRC_DIR}"
    if [[ $M2_BACKUP_TYPE = @(db|database|all) ]]; then
        echo " >> Database Dump File    : ${M2_DB_BACKUP_FILE}"
    fi

    if [[ $M2_BACKUP_TYPE = @(codebase|code|all) ]]; then
        echo " >> Codebase Archive File : ${M2_CODE_BACKUP_FILE}"
    fi

    echo ""
    echo "################################################################"
    _printPoweredBy

}

################################################################################
# Main
################################################################################
export LC_CTYPE=C
export LANG=C

DEBUG=0
_debug set -x
VERSION="0.2.0"

M2_SRC_DIR=
M2_DEST_DIR=
M2_BACKUP_DB=0
M2_BACKUP_CODE=0
M2_USE_MYSQL_CONFIG=0
M2_SKIP_MEDIA=0
M2_BACKUP_NAME=
M2_DB_BACKUP_FILE=
M2_CODE_BACKUP_FILE=

function main()
{
    [[ $# -lt 1 ]] && _printUsage

    processArgs "$@"

    prepareBackupName
    prepareCodebaseFilename
    prepareDatabaseFilename

    if [[ "$M2_BACKUP_DB" -eq 1 ]]; then
        createDbBackup
    fi

    if [[ "$M2_BACKUP_CODE" -eq 1 ]]; then
        createCodeBackup
    fi

    printSuccessMessage

    exit 0
}

main "$@"

_debug set +x
