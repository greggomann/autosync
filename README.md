# autosync
Automatically keep a local build directory in sync with a remote.

## Dependencies
[fswatch](https://github.com/emcrisostomo/fswatch)

## Usage
```bash
./autosync.sh [remote_username] [ssh_key_file] [host_ip] [machine_id]
```

When you run `autosync.sh` in a given directory, it syncs the remote machine
such that it contains a directory of the same name within `REMOTE_DEV_DIR`, as
defined in the script. `ssh_key_file` is the path of the SSH key that will be
used to connect to the remote machine. The first time you run it for a given
platform you must specify the host IP. Subsequent executions will use the stored
IP for the specified `machine_id` unless it is specified again. `machine_id`
defaults to the value `default` if not provided.

An `fswatch` process is run in the background and logs its output within
`AUTOSYNC_DIR`, as defined in the script.

See the top of the script for the definition of constants that you may want to
alter.
