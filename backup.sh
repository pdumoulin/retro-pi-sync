#!/bin/bash

# uploading to retropi or downloading from retropi
MODE=$1
if [[ ( -z "$MODE" ) || ( "$MODE" != "down" && "$MODE" != "up") ]]; then
    echo "\$1 must be set to 'up' or 'down'"
    exit
fi

# color for clearer output
echo_green () {
    echo -e "\033[0;32m$1\033[0m"
};

# remote retropi locations
REMOTE_USER=pi
REMOTE_IP=192.168.1.151

# rsync command to use
RSYNC_OPTS="rsync -avz -e ssh"

# tuples of directories to sync (remote local)
DIRS=( 
    "/home/pi/RetroPie/BIOS/ ./bios/"
    "/home/pi/RetroPie/roms/ ./roms/" 
    "/home/pi/.emulationstation/downloaded_images/ ./downloaded_images/" 
    "/home/pi/.emulationstation/gamelists/ ./gamelists/" 
)


# stop emulation station if uploading files
if [ "$MODE" == "up" ]; then
    echo_green "Stopping emulationstation"
    ssh $REMOTE_USER@$REMOTE_IP killall emulationstation
    echo ""
fi

# sync local and remote directories
for i in "${DIRS[@]}"
do
    set -- $i
    mkdir -p $2
    if [ "$MODE" == "down" ]; then
        echo_green "Downloading from $1 to $2"
        $RSYNC_OPTS $REMOTE_USER@$REMOTE_IP:$1 $2
    elif [ "$MODE" == "up" ]; then
        echo_green "Uploading from $2 to $1"
        $RSYNC_OPTS $2 $REMOTE_USER@$REMOTE_IP:$1
    fi
    echo ""
done

# re-start emulation station if uploaded files
if [ "$MODE" == "up" ]; then
    echo_green "Starting emulationstation"
    ssh -tt $REMOTE_USER@$REMOTE_IP nohup emulationstation &
    ssh $REMOTE_USER@$REMOTE_IP ps -aux | grep emulationstation
    echo ""
fi

