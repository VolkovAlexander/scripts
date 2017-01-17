#!/bin/bash

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"

# Vars
DIR_PERSONAL="/var/www/vhosts/personalweb_$USER"
PROJECTS=("zadarma.com")
PROJECT_DIR=""
PROJECT_GIT_PATH=""

# Functions
function executeCommandWithCatching() {
    $1
    if [ $? -ne 0 ]; then
        exit 0
    fi
}

clear
echo -e "$COL_GREEN Deployment tool for ZADARMA projects $COL_RESET\n"

echo -e -n "\n$COL_BLUE checking software...\t\t\t\t$COL_RESET"

git --version 2>&1 >/dev/null # improvement by tripleee
GIT_IS_AVAILABLE=$?
if [ ! $GIT_IS_AVAILABLE -eq 0 ]; then
    echo -e "$COL_RED failed (git not installed)\n\n$COL_RESET"
    exit 0
fi

composer --version 2>&1 >/dev/null # improvement by tripleee
COMPOSER_IS_AVAILABLE=$?
if [ ! $COMPOSER_IS_AVAILABLE -eq 0 ]; then
    echo -e "$COL_RED failed (composer not installed)\n\n$COL_RESET"
    exit 0
fi

echo -e "$COL_GREEN success$COL_RESET"

echo -e -n "$COL_BLUE pick porject, that you want to deploy:\n"

echo -e "$COL_YELLOW"
select PROJECT in "${PROJECTS[@]}"
do
    case $PROJECT in
        "zadarma.com")
            PROJECT_DIR="zadarma.com"
            PROJECT_GIT_PATH="webcore_zadarma"
            break;
            ;;
        *) echo invalid option;;
    esac
done
echo -e "$COL_RESET"

echo -e -n "\n$COL_BLUE checking for folder right structure...\t\t$COL_RESET"
if [ -d "$DIR_PERSONAL" ]; then
    echo -e "$COL_GREEN success$COL_RESET"
else
    echo -e "$COL_RED failed ($DIR_PERSONAL directory not found)\n\n$COL_RESET"
    exit 0
fi

echo -e -n "$COL_BLUE creating new folders for new project...\t$COL_RESET"
executeCommandWithCatching "mkdir -p $DIR_PERSONAL/webcore/configs"
executeCommandWithCatching "mkdir -p $DIR_PERSONAL/webcore/webcore_base"
executeCommandWithCatching "mkdir -p $DIR_PERSONAL/webcore/www"
executeCommandWithCatching "ln -sf $DIR_PERSONAL/webcore/webcore_base/app.php $DIR_PERSONAL/webcore/app.php"
executeCommandWithCatching "ln -sf $DIR_PERSONAL/webcore/webcore_base/base $DIR_PERSONAL/webcore/base"
executeCommandWithCatching "ln -sf $DIR_PERSONAL/webcore/webcore_base/components $DIR_PERSONAL/webcore/components"
executeCommandWithCatching "ln -sf $DIR_PERSONAL/webcore/webcore_base/extensions $DIR_PERSONAL/webcore/extensions"
executeCommandWithCatching "ln -sf $DIR_PERSONAL/webcore/webcore_base/vendor $DIR_PERSONAL/webcore/vendor"
echo -e "$COL_GREEN success$COL_RESET"

echo -e -n "$COL_BLUE cloning webcore repository from git...\n\n$COL_RESET"
if [ "$(ls -A $DIR_PERSONAL/webcore/webcore_base)" ]; then
    executeCommandWithCatching "cd $DIR_PERSONAL/webcore/webcore_base"
    executeCommandWithCatching "git pull"
else
    executeCommandWithCatching "git clone git.sipdc.net:/webcore.code $DIR_PERSONAL/webcore/webcore_base"
fi
echo -e "\n"

echo -e -n "$COL_BLUE installing vendor packets by composer...\n\n$COL_RESET"
executeCommandWithCatching "cd $DIR_PERSONAL/webcore/webcore_base"
executeCommandWithCatching "composer install"
echo -e "\n"

echo -e -n "$COL_BLUE cloning configs repository from git...\n\n$COL_RESET"
if [ "$(ls -A $DIR_PERSONAL/webcore/configs)" ]; then
    executeCommandWithCatching "cd $DIR_PERSONAL/webcore/configs"
    executeCommandWithCatching "git pull"
else
    executeCommandWithCatching "git clone git.sipdc.net:/sandbox/webcore_config $DIR_PERSONAL/webcore/configs"
fi
echo -e "\n"

echo -e -n "$COL_BLUE cloning project repository from git...\n\n$COL_RESET"
if [ "$(ls -A $DIR_PERSONAL/webcore/www/$PROJECT_DIR)" ]; then
    executeCommandWithCatching "cd $DIR_PERSONAL/webcore/www/$PROJECT_DIR"
    executeCommandWithCatching "git pull"
else
    executeCommandWithCatching "mkdir $DIR_PERSONAL/webcore/www/$PROJECT_DIR"
    executeCommandWithCatching "git clone git.sipdc.net:$PROJECT_GIT_PATH $DIR_PERSONAL/webcore/www/$PROJECT_DIR"
fi
echo -e "\n"

echo -e -n "$COL_BLUE creating symlink for new active project...\t$COL_RESET"
executeCommandWithCatching "ln -sf $DIR_PERSONAL/webcore/www/$PROJECT_DIR/public_html $DIR_PERSONAL/html"
executeCommandWithCatching "ln -sf $DIR_PERSONAL/webcore/configs $DIR_PERSONAL/webcore/webcore_base/configs"
executeCommandWithCatching "ln -sf $DIR_PERSONAL/webcore/www $DIR_PERSONAL/webcore/webcore_base/www"
echo -e "$COL_GREEN success$COL_RESET"

echo -e -n "$COL_BLUE creating .env file for additional data...\t$COL_RESET"
if [ ! -f "$DIR_PERSONAL/webcore/webcore_base/.env" ]; then
    echo 'APP_ENV=local
ENABLE_EXCEPTION_HANDLER=true
config_languages[pl]=pl_PL

config_db[db1][connectionString]=mysql:host=mysql-dev.fr.sipdc.priv:3306;dbname=web_frontend
config_db[db1][username]=web_frontend
config_db[db1][password]=

config_db[db_ss][connectionString]=mysql:host=mysql-dev.fr.sipdc.priv:3306;dbname=ss
config_db[db_ss][username]=ss
config_db[db_ss][password]=

config_memcache[host]=

config_redis[host]=
config_redis[password]=
        ' > "$DIR_PERSONAL/webcore/webcore_base/.env"
fi
echo -e "$COL_GREEN success (don't forget fill all empty places)\n\n Deplyoment successfully end\n\n$COL_RESET"


