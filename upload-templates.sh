#!/bin/bash


# Exit on error
set -e

# Exit on error
WP_USER="${WP_USER}"

# Configuration
SSH_HOST="${SSH_HOST}"           # SSH username
SSH_USER="${WP_USER}"          # Server IP or domain
SSH_PORT="${SSH_PORT}"                      # SSH port (default is 22)

WP_CONTENT_DIR="/home/${WP_USER}/public_html/wp-content"  # Path to WordPress content directory on the server
TEMPLATE_KIT_PATH="${LOCAL_TEMPLATE_KIT_PATH}" 

# Step 1: Upload the Template Kit
echo "Uploading the Template Kit to the server..."
scp -P "$SSH_PORT" "$LOCAL_TEMPLATE_KIT_PATH" "$SSH_USER@$SSH_HOST:${REMOTE_TEMPLATE_KIT_PATH}"


# Step 3: Run the PHP Script to Import the Template Kit
echo "Running the PHP script to import the Template Kit..."
ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" bash << EOF
    export WP_CONTENT_DIR="$WP_CONTENT_DIR"
    cd "${WP_CONTENT_DIR}/../"
    wp eval-file << 'PHP'
<?php
$template_kit_path = getenv('REMOTE_TEMPLATE_KIT_PATH') . '/uploads/;

if (file_exists($template_kit_path)) {
    require_once ABSPATH . 'wp-admin/includes/file.php';
    require_once ABSPATH . 'wp-admin/includes/plugin.php';

    if (!is_plugin_active('elementor/elementor.php')) {
        echo "Elementor is not activated.";
        exit;
    }

    // Import the template kit
    $imported = \Elementor\Plugin::$instance->kits_manager->import_template_kit($template_kit_path);

    if ($imported) {
        echo "Template Kit imported successfully!";
    } else {
        echo "Failed to import the Template Kit.";
    }
} else {
    echo "Template Kit file not found at $template_kit_path.";
}
?>
PHP
EOF

echo "Elementor Template Kit installation complete!"


ssh -p "$SSH_PORT" "$SSH_USER@$SSH_HOST" bash << EOF
    export WP_CONTENT_DIR="$WP_CONTENT_DIR"
    cd "${WP_CONTENT_DIR}/../"
    wp eval-file << 'PHP'
<?php
$template_kit_path = getenv('WP_CONTENT_DIR') . '/uploads/elementor-template-kit.zip';

if (file_exists($template_kit_path)) {
    require_once ABSPATH . 'wp-admin/includes/file.php';
    require_once ABSPATH . 'wp-admin/includes/plugin.php';

    if (!is_plugin_active('elementor/elementor.php')) {
        echo "Elementor is not activated.";
        exit;
    }

    // Import the template kit
    $imported = \Elementor\Plugin::$instance->kits_manager->import_template_kit($template_kit_path);

    if ($imported) {
        echo "Template Kit imported successfully!";
    } else {
        echo "Failed to import the Template Kit.";
    }
} else {
    echo "Template Kit file not found at $template_kit_path.";
}
?>
PHP
EOF

echo "Elementor Template Kit installation complete!"