#!/bin/bash

# This script checks for a mount point, mounts a USB drive by UUID,
# performs an rsync synchronization, and unmounts the drive if rsync is successful.

# --- Configuration Variables ---
# IMPORTANT: Replace these placeholder values with your actual details.

# The UUID of your external USB drive.
# You can find this using 'blkid' or 'lsblk -f' command.
USB_UUID=""

# The directory where you want to mount the USB drive.
# Make sure this path exists or will be created by the script.
MOUNT_POINT=""

# The source directory containing the files you want to sync TO the USB drive.
# Ensure this path is correct.
SOURCE_DIR=""

# --- Rsync Exclusions ---
# Define the directories or files you want to exclude.
# Each item in this array will become an '--exclude' argument for rsync.
# Paths are relative to the SOURCE_DIR.
# Example:
# EXCLUDE_DIRS=(
#     "temp_files/"      # Exclude a directory named 'temp_files'
#     "cache/"           # Exclude 'cache' directory
#     "*.log"            # Exclude all .log files
#     "my_secret_data/"  # Exclude a directory with spaces if quoted
# )

EXCLUDE_DIRS=(
)

# Convert the array into rsync's --exclude arguments
# This creates an array where each element is '--exclude PATTERN'
RSYNC_EXCLUDES=()
for dir in "${EXCLUDE_DIRS[@]}"; do
    RSYNC_EXCLUDES+=(--exclude "$dir")
done

# --- Script Logic ---

echo "Starting USB sync script..."

# 1. Check if the mount point directory exists, create it if not.
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Mount point '$MOUNT_POINT' does not exist. Creating it..."
    sudo mkdir -p "$MOUNT_POINT"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create mount point '$MOUNT_POINT'. Exiting."
        exit 1
    fi
    echo "Mount point created."
fi

# 2. Check if the drive is already mounted at the desired mount point.
if mountpoint -q "$MOUNT_POINT"; then
    echo "Drive is already mounted at '$MOUNT_POINT'. Skipping mount step."
else
    # 3. Mount the USB drive by UUID.
    echo "Attempting to mount USB drive with UUID '$USB_UUID' to '$MOUNT_POINT'..."
    sudo mount -U "$USB_UUID" "$MOUNT_POINT"
    if [ $? -ne 0 ]; then
        echo "Error: Failed to mount USB drive with UUID '$USB_UUID'. Please check UUID and permissions."
        exit 1
    fi
    echo "USB drive mounted successfully."
fi

# 4. Run the rsync job.
#    -a: archive mode (preserves permissions, ownership, timestamps, etc.)
#    -v: verbose (show what's being transferred)
#    -h: human-readable numbers
#    --delete: deletes extraneous files from destination dir (not in source)
#    Trailing slashes are important:
#    "$SOURCE_DIR/": syncs the *contents* of SOURCE_DIR
#    "$MOUNT_POINT/": syncs into the *root* of the mounted drive
echo "Starting rsync synchronization from '$SOURCE_DIR' to '$MOUNT_POINT'..."
rsync_result=0 # Initialize rsync_result
sudo rsync -avh --progress --delete --delete-excluded "${RSYNC_EXCLUDES[@]}" "$SOURCE_DIR/" "$MOUNT_POINT/"
rsync_result=$? # Capture the exit status of rsync

if [ $rsync_result -eq 0 ]; then
    echo "Rsync completed successfully."
    # 5. Unmount the drive only if rsync was successful.
    echo "Attempting to unmount '$MOUNT_POINT'..."
    sudo umount "$MOUNT_POINT"
    if [ $? -ne 0 ]; then
        echo "Warning: Rsync was successful, but failed to unmount '$MOUNT_POINT'. You may need to unmount manually."
        exit 0 # Rsync was successful, so exit with 0 even if unmount failed.
    fi
    echo "USB drive unmounted successfully."
    echo "Script finished: Rsync and unmount successful."
    exit 0
else
    echo "Error: Rsync failed with exit code $rsync_result. Not unmounting the drive."
    echo "Please check the rsync output for errors."
    # Attempt to unmount anyway if rsync failed, just in case, but warn the user.
    # You might want to remove this auto-unmount on rsync failure depending on your needs.
    echo "Attempting to unmount '$MOUNT_POINT' despite rsync failure (optional cleanup)..."
    sudo umount "$MOUNT_POINT" 2>/dev/null # Redirect stderr to /dev/null to suppress "not mounted" errors
    echo "Script finished: Rsync failed."
    exit $rsync_result # Exit with rsync's error code
fi
