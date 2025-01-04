<?php
// Place this script in your WordPress installation and run it via WP-CLI or a browser.

// Define the template kit file path
$template_kit_path = WP_CONTENT_DIR . '/uploads/elementor-template-kit.zip';

if (file_exists($template_kit_path)) {
    require_once ABSPATH . 'wp-admin/includes/file.php';
    require_once ABSPATH . 'wp-admin/includes/plugin.php';

    // Ensure Elementor and its dependencies are active
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