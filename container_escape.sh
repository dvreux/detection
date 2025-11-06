#!/bin/bash
echo "=== Container Escape Attempts ==="
echo ""

# Attempt 1: Check for available binaries
echo "[1] Available Privileged Binaries:"
which python3 python2 perl php gcc cc g++ curl wget nc netcat 2>/dev/null

# Attempt 2: SUID Binaries in Container
echo ""
echo "[2] SUID Binaries in Container:"
find / -perm -4000 -type f 2>/dev/null | head -20

# Attempt 3: Capabilities Check
echo ""
echo "[3] Capabilities:"
getcap -r / 2>/dev/null | head -10

# Attempt 4: Mount Points Escape
echo ""
echo "[4] Mount Points Analysis:"
mount | grep -v virtfs | grep -v "ro,"

# Attempt 5: Proc Filesystem Exploitation
echo ""
echo "[5] Proc FS Analysis:"
ls -la /proc/1/root/ 2>/dev/null && echo "Host FS accessible via /proc/1/root" || echo "Proc escape not available"

# Attempt 6: Shared Library Hijacking
echo ""
echo "[6] Library Path:"
echo $LD_LIBRARY_PATH
ldd /bin/ls 2>/dev/null | head -5

# Attempt 7: System Call Check
echo ""
echo "[7] System Calls:"
cat > /tmp/syscall_test.c << 'EOF'
#define _GNU_SOURCE
#include <sys/syscall.h>
#include <stdio.h>
#include <unistd.h>

int main() {
    printf("Available syscalls:\n");
    #ifdef SYS_chroot
    printf("chroot: %d\n", SYS_chroot);
    #endif
    #ifdef SYS_mount  
    printf("mount: %d\n", SYS_mount);
    #endif
    #ifdef SYS_pivot_root
    printf("pivot_root: %d\n", SYS_pivot_root);
    #endif
    return 0;
}
EOF
gcc /tmp/syscall_test.c -o /tmp/syscall_test 2>/dev/null && /tmp/syscall_test

# Attempt 8: Namespace Escape
echo ""
echo "[8] Namespace Check:"
ls -la /proc/self/ns/ 2>/dev/null
cat /proc/self/uid_map 2>/dev/null | head -5

# Attempt 9: Device Access
echo ""
echo "[9] Device Access:"
ls -la /dev/ 2>/dev/null | grep -E "(sda|disk|memory|kmem)" | head -5

# Attempt 10: Kernel Module Injection
echo ""
echo "[10] Kernel Info:"
uname -a
cat /proc/modules 2>/dev/null | head -5

# Cleanup
rm -f /tmp/syscall_test.c /tmp/syscall_test 2>/dev/null