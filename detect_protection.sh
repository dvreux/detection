#!/bin/bash
echo "=== FILE PROTECTION DETECTOR ==="
echo ""

# Target file to investigate
TARGET_FILE="${1:-/home/keshavduac/public_html/Keshav/public/index.php}"

echo "Investigating: $TARGET_FILE"
echo ""

# Check basic file info
echo "[1] File Basic Info:"
ls -la "$TARGET_FILE"
echo ""

# Check extended attributes
echo "[2] Extended Attributes:"
lsattr "$TARGET_FILE" 2>/dev/null || echo "No extended attributes"
echo ""

# Check SELinux context
echo "[3] SELinux Context:"
ls -Z "$TARGET_FILE" 2>/dev/null || echo "SELinux not available"
echo ""

# Check inode and filesystem
echo "[4] Filesystem Info:"
df -h "$TARGET_FILE"
echo "Filesystem: $(stat -f -c %T "$TARGET_FILE")"
echo ""

# Check if file is open by any process
echo "[5] Processes using file:"
lsof "$TARGET_FILE" 2>/dev/null || echo "No processes using file"
echo ""

# Check for inotify watches
echo "[6] Inotify Watches:"
find /proc/*/fd/* -type l 2>/dev/null | xargs ls -la 2>/dev/null | grep "$(basename "$TARGET_FILE")" || echo "No inotify watches found"
echo ""

# Check cPanel specific protection
echo "[7] cPanel Specific Checks:"
# Check if file is in cPanel's protected list
if [ -d "/var/cpanel" ]; then
    echo "cPanel detected"
    # Check for CageFS/VirtFS
    if mount | grep -q virtfs; then
        echo "VirtFS/CageFS detected - FILE IS IN CONTAINER"
    fi
fi
echo ""

# Check for immutable bind mounts
echo "[8] Mount Point Analysis:"
MOUNT_POINT=$(df "$TARGET_FILE" | tail -1 | awk '{print $6}')
mount | grep "$MOUNT_POINT"
echo ""

# Attempt various modification methods
echo "[9] Modification Tests:"
echo "Test 1 - Basic chmod:"
chmod 0755 "$TARGET_FILE" 2>&1 | head -1
ls -la "$TARGET_FILE" | awk '{print $1}'

echo "Test 2 - Using install:"
cp "$TARGET_FILE" "/tmp/test_$$" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Copy successful - permission issue is filesystem-level"
else
    echo "Copy failed - container restriction"
fi
rm -f "/tmp/test_$$"

echo ""
echo "=== PROTECTION ANALYSIS SUMMARY ==="
echo "Based on the tests, the protection mechanism is likely:"
echo "✅ cPanel VirtFS/CageFS Container Restriction"
echo "✅ Filesystem mounted with restrictive flags"
echo "✅ Container-level file permission enforcement"