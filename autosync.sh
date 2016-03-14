#!/usr/bin/env bash
################################################################################
# Sync a build directory with a remote machine automatically.
#
# Dependency: fswatch (https://github.com/emcrisostomo/fswatch)
#
################################################################################

AUTOSYNC_DIR=$HOME/.autosync
#REMOTE_DEV_DIR="\\\$HOME/src"
REMOTE_DEV_DIR="/mnt/src"
SSH_KEY=$HOME/.ssh/greg.pem

# Note: all arguments except `machine_id` and `host_ip` are required. On the
#       first run of this script, `host_ip` must be provided.
USAGE="Usage: ./autosync.sh [remote_username] \
[ssh_key_file] [host_ip] [machine_id]"

# Create the log directory if necessary.
if [ ! -e "$AUTOSYNC_DIR" ]; then
  mkdir -p $AUTOSYNC_DIR
fi

if [ -z "$1" ]; then
  echo "ERROR: No arguments were provided"
  echo $USAGE
  exit 1
else
  remote_username=$1
fi

if [ -z "$2" ]; then
  echo "ERROR: SSH key file was not provided"
  exit 1
else
  ssh_key=$2
fi

if [ -z "$4" ]; then
  machine_id="default"
else
  machine_id=$4
fi

config_file=$AUTOSYNC_DIR/${machine_id}.conf

# Populate the host IP.
if [ -z "$3" ]; then
  # Make sure the IP has already been stored.
  if [ ! -e $config_file ] || [ ! -s $config_file ]; then
    echo "If no IP is provided, it must be specified in $config_file."
    exit 1
  fi

  host_ip=`grep "${machine_id}_ip" $config_file | awk '{print $2}'`
else
  host_ip=$3

  # Store this IP for later use, associated with the current `machine_id`.
  echo "${machine_id}_ip $host_ip" > $config_file
fi

# The current directory name, without the full path.
current_dir=${PWD##*/}

target_dir=$DEV_DIR/$current_dir

# Store the rsync command.
rsync_command="rsync -avz --rsync-path=\"sudo mkdir -p                         \
  $REMOTE_DEV_DIR/$current_dir && sudo chown -R                                \
  $remote_username:$remote_username $REMOTE_DEV_DIR && rsync\" --delete        \
  --exclude=\".git/*\" --exclude=\"build/*\" -e \"ssh -i $ssh_key -l           \
  $remote_username\" . $remote_username@$host_ip:$REMOTE_DEV_DIR/$current_dir"

# Perform an initial sync.
eval $rsync_command

# Start up the background process.
eval "fswatch -0 -o -e .git/ . | xargs -0 -I {} $rsync_command >               \
  $AUTOSYNC_DIR/${machine_id}.log 2>&1 &"

