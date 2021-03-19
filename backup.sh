#!/bin/bash


SERVER_NAME=funny #can be changed using $1, i.e. executing the script "./backup.sh servername"
BACKUP_FILE_NAME_WORLD=$(date "+%Y.%m.%d-%H.%M")_server-$SERVER_NAME.7z
BACKUP_FILE_NAME_SERVER=$(date "+%Y.%m.%d-%H.%M")_world-$SERVER_NAME.7z
MONTH_FOLDER_NAME=$(date "+%B")
RCLONE_UPLOAD_REMOTE=mc:/

# default settings
#
# mc:
# └── February
#     └── server
#         ├── 2021.02.01-22.00_server-funny.7z
#         ├── 2021.02.02-22.00_server-funny.7z
#         ├── 2021.02.02-22.00_server-funny.7z
#     └── world
#         ├── 2021.02.01-22.00_world-funny.7z
#         ├── 2021.02.02-22.00_world-funny.7z
#         └── 2021.02.02-22.00_world-funny.7z
# └── March
#     └── server
#         ├── 2021.03.01-22.00_server-funny.7z
#         ├── 2021.03.02-22.00_server-funny.7z
#         ├── 2021.03.02-22.00_server-funny.7z
#     └── world
#         ├── 2021.03.01-22.00_world-funny.7z
#         ├── 2021.03.02-22.00_world-funny.7z
#         └── 2021.03.02-22.00_world-funny.7z
#

SERVER_DIR=/opt/minecraft
TMP_DIR=$HOME/tmp

############################################
## NO NECESSARY CHANGES BEYOND THIS LINE! ##
############################################

# check if there is a $1 (an argument)
# if its empty, dont do anything
# if its not empty, set SERVER_NAME to $1
if [ -z "$1" ]; then
	sleep 0
else
    SERVER_NAME=$1
fi
#stop minecraft server
#be sure you have set sudo to "NOPASSWD" for the user that is gonna be executing this script
echo "backing up minecraft server $SERVER_NAME"
echo "stopping minecraft server..."
sudo systemctl stop mc@$SERVER_NAME


#backup world
echo "creating archives..."
#sleep 3
if [ -d "$SERVER_DIR/$SERVER_NAME/world_nether" ] || [ -d "$SERVER_DIR/$SERVER_NAME/world_the_end" ]; then
		7z a $TMP_DIR/$MONTH_FOLDER_NAME/world/$BACKUP_FILE_NAME_WORLD $SERVER_DIR/$SERVER_NAME/world $SERVER_DIR/$SERVER_NAME/world_nether $SERVER_DIR/$SERVER_NAME/world_the_end -mx0
	else
		7z a $TMP_DIR/$MONTH_FOLDER_NAME/world/$BACKUP_FILE_NAME_WORLD $SERVER_DIR/$SERVER_NAME/world -mx0
fi

#backup server
7z a $TMP_DIR/$MONTH_FOLDER_NAME/server/$BACKUP_FILE_NAME_SERVER $SERVER_DIR/$SERVER_NAME -mx0

echo ""
echo "starting minecraft server..."
echo "uploading the files to $RCLONE_UPLOAD_REMOTE"
echo ""
sudo systemctl start mc@$SERVER_NAME

rclone move $TMP_DIR $RCLONE_UPLOAD_REMOTE --delete-empty-src-dirs -v
