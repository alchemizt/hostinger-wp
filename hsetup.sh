#!/bin/bash


# Exit on error
set -e

# Exit on error
WP_USER="${WP_USER}"

# Configuration
SSH_HOST="${SSH_HOST}"           # SSH username
SSH_USER="${WP_USER}"          # Server IP or domain
SSH_PORT="${SSH_PORT}"                      # SSH port (default is 22)

# Configuration

WP_URL="${WP_URL}"
REMOTE_WP_PATH="/home/${WP_USER}/domains/${WP_URL}/public_html"  # Path to WordPress installation
PHP_INI_PATH="/etc/php/7.4/fpm/php.ini"  # Path to the PHP ini file
LOCAL_PREMIUM_PLUGIN_PATH="./files/plugins/elementor"  # Local path where premium plugins are stored
THEMES=("hello-elementor" "astra")  # List of themes to install
PLUGINS=("elementor" "classic-editor" "contact-form-7" "envato-elements")  # List of free plugins to install
PREMIUM_PLUGINS=("elementor-pro.zip")  # List of premium plugin ZIP files (local)


# Step 1: Upload Premium Plugins to the Server
echo "Uploading premium plugins to the server..."
for plugin_zip in "${PREMIUM_PLUGINS[@]}"; do
    if [ -f "$LOCAL_PREMIUM_PLUGIN_PATH/$plugin_zip" ]; then
        scp -P "$SSH_PORT" "$LOCAL_PREMIUM_PLUGIN_PATH/$plugin_zip" "$SSH_USER@$SSH_HOST:$REMOTE_WP_PATH/wp-content/plugins/"
        echo "Uploaded: $plugin_zip"
    else
        echo "File not found: $LOCAL_PREMIUM_PLUGIN_PATH/$plugin_zip"
    fi
done

# Step 2: Connect to the Server via SSH and Run Commands
echo "Connecting to the server via SSH..."
ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" bash << EOF
    set -e
    echo "Connected to the server. Starting WordPress setup..."

    # Step 3: Update WordPress Core
    echo "Updating WordPress core..."
    cd "$REMOTE_WP_PATH"
    wp core update

    # Step 4: Install and Activate Themes
    echo "Installing and activating themes..."
EOF

# Add theme installation commands to the remote script
for theme in "${THEMES[@]}"; do
    ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" << EOF
    cd "$REMOTE_WP_PATH"
    wp theme install "$theme" --activate
EOF
done

# Step 5: Install and Activate Free Plugins
echo "Installing and activating free plugins..."
for plugin in "${PLUGINS[@]}"; do
    ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" << EOF
    cd "$REMOTE_WP_PATH"
    wp plugin install "$plugin" --activate
EOF
done

# Step 6: Activate Premium Plugins
echo "Activating premium plugins..."
for plugin_zip in "${PREMIUM_PLUGINS[@]}"; do
    plugin_name=\$(basename "\$plugin_zip" .zip)
    ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" << EOF
    cd "$REMOTE_WP_PATH"
    wp plugin activate "\$plugin_name"
EOF
done

# # Step 7: Modify PHP ini Settings
# echo "Modifying PHP ini settings..."
# ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" << EOF
#     sudo sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 64M/' "$REMOTE_PHP_INI_PATH"
#     sudo sed -i 's/^post_max_size = .*/post_max_size = 64M/' "$REMOTE_PHP_INI_PATH"
#     sudo sed -i 's/^memory_limit = .*/memory_limit = 256M/' "$REMOTE_PHP_INI_PATH"
#     sudo sed -i 's/^max_execution_time = .*/max_execution_time = 300/' "$REMOTE_PHP_INI_PATH"
#     sudo sed -i 's/^max_input_time = .*/max_input_time = 300/' "$REMOTE_PHP_INI_PATH"
#     sudo systemctl restart php7.4-fpm
# EOF