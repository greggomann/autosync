# autosync
Automatically keep a local build directory in sync with a remote.

## Dependencies
[fswatch](https://github.com/emcrisostomo/fswatch)

## Assumptions
* We assume that the specified platform has a username defined in the `case`
  statement in the script. This username is used to log in to the remote.

## Usage
```bash
./autosync.sh [platform] [host IP]
```

When you run `autosync.sh` in a given directory, it syncs the remote such that
it contains a directory of the same name within `REMOTE_DEV_DIR`, as defined in
the script. The first time you run it for a given platform you must specify the
host IP. Subsequent executions will use the stored IP unless it is specified
again.

The fswatch process is run in the background and logs its output within
`AUTOSYNC_DIR`, as defined in the script.

See the top of the script for constant definitions that you may want to alter.
