#!/usr/bin/env bash
################################################################################
# Sync a build directory with a remote machine automatically.
#
# Dependency: fswatch (https://github.com/emcrisostomo/fswatch)
#
# Assumptions:
#   * We assume that the current directory's name will be found as a first-level
#     child directory of the REMOTE_DEV_DIR.
#   * We assume that the platform has had a username defined in the `case`
#     statement below.
#
# Usage: ./autosync.sh [platform] [host IP]
################################################################################

DEFAULT_PLATFORM=centos
AUTOSYNC_DIR=$HOME/.autosync
REMOTE_DEV_DIR="\\\$HOME/src"
SSH_KEY=$HOME/.ssh/default.pem

# Create the log directory if necessary.
if [ ! -e "$AUTOSYNC_DIR" ]; then
  mkdir -p $AUTOSYNC_DIR
fi

# Populate the platform name.
if [ -z "$1" ]; then
  platform=$DEFAULT_PLATFORM
else
  platform=$1
fi

# Set the remote username.
case $platform in
centos)
  remote_username=root
  ;;
ubuntu)
  remote_username=ubuntu
  ;;
*)
  echo "You specified an undefined platform."
  exit 1
  ;;
esac

config_file=$AUTOSYNC_DIR/${platform}.conf

# Populate the host IP.
if [ -z "$2" ]; then
  # Make sure the IP has already been stored.
  if [ ! -e $config_file ] || [ ! -s $config_file ]; then
    echo "If no IP is provided, it must be specified in $config_file."
    exit 1
  fi

  host_ip=`grep "${platform}_ip" $config_file | awk '{print $2}'`
else
  host_ip=$2

  # Store this IP for later use.
  echo "${platform}_ip $2" > $config_file
fi

# The current directory name, without the full path.
current_dir=${PWD##*/}

target_dir=$DEV_DIR/$current_dir

# Store the rsync command.
rsync_command="rsync -avz --rsync-path=\"mkdir -p $REMOTE_DEV_DIR/$current_dir \
  && rsync\" --delete --exclude=\".git/*\" --exclude=\"build/*\" -e \"ssh -i   \
  $SSH_KEY -l $remote_username\" .                                             \
  $remote_username@$host_ip:$REMOTE_DEV_DIR/$current_dir"

# Perform an initial sync.
eval $rsync_command

# Start up the background process.
eval "fswatch -0 -o -e .git/ . | xargs -0 -I {} $rsync_command >               \
  $AUTOSYNC_DIR/${platform}.log 2>&1 &"

