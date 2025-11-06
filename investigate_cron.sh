#!/bin/bash
echo "=== CRON INVESTIGATION TOOL ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[1] Checking Current User Cron Jobs...${NC}"
echo "Current user: $(whoami)"
crontab -l 2>/dev/null || echo "No cron jobs for current user"

echo ""
echo -e "${YELLOW}[2] Checking System Cron Directories...${NC}"
for dir in /etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly; do
    if [ -d "$dir" ]; then
        echo "=== $dir ==="
        ls -la "$dir" 2>/dev/null | head -10
    fi
done

echo ""
echo -e "${YELLOW}[3] Checking /etc/crontab...${NC}"
if [ -r "/etc/crontab" ]; then
    cat /etc/crontab
else
    echo "Cannot read /etc/crontab"
fi

echo ""
echo -e "${YELLOW}[4] Checking Recent Cron Execution...${NC}"
# Try different log locations
for log in /var/log/cron /var/log/syslog /var/log/messages; do
    if [ -f "$log" ]; then
        echo "=== Last 10 entries from $log ==="
        grep -i cron "$log" | tail -10
    fi
done

echo ""
echo -e "${YELLOW}[5] Checking Suspicious Processes...${NC}"
ps aux | grep -E '(wget|curl|nc|netcat|python|perl|bash|sh)\s' | grep -v grep

echo ""
echo -e "${YELLOW}[6] Checking Network Connections...${NC}"
netstat -tunlp 2>/dev/null | grep -v "127.0.0.1" || ss -tunlp 2>/dev/null | grep -v "127.0.0.1"

echo ""
echo -e "${YELLOW}[7] Checking /tmp and /dev/shm for suspicious files...${NC}"
ls -la /tmp/ | head -10
ls -la /dev/shm/ 2>/dev/null | head -10

echo ""
echo -e "${YELLOW}[8] Checking for Hidden Files in Home Directory...${NC}"
find ~ -name ".*" -type f -exec file {} \; 2>/dev/null | grep -E "(script|executable|binary)"

echo ""
echo -e "${YELLOW}[9] Checking SUID/SGID Files...${NC}"
find / -perm -4000 -o -perm -2000 2>/dev/null | head -20

echo ""
echo -e "${YELLOW}[10] Checking Writable Directories...${NC}"
find / -type d -writable 2>/dev/null | grep -v -E "(proc|sys|dev)" | head -20

echo ""
echo -e "${YELLOW}[11] Checking VirtFS Specific Mounts...${NC}"
mount | grep virtfs
mount | grep $(whoami)

echo ""
echo -e "${YELLOW}[12] Checking cPanel Specific...${NC}"
# cPanel specific locations
for dir in /usr/local/cpanel /var/cpanel /etc/cpanel; do
    if [ -d "$dir" ]; then
        echo "=== $dir exists ==="
    fi
done

echo ""
echo -e "${GREEN}Investigation Complete!${NC}"