# Per-App DPI on Geely Monjaro with Root (Without WM Command)

With root access, you have several methods to change DPI for individual apps without using the `wm` command:

## Method 1: Xposed Framework with App Settings Module

### Install Xposed/EdXposed/LSPosed:
```bash
# Check Android version and architecture
adb shell getprop ro.build.version.release
adb shell getprop ro.product.cpu.abi

# For Android 9, use EdXposed or Riru-LSPosed
# Install Magisk first, then install the framework
```

### Install App Settings Module:
1. Download "App Settings" Xposed module
2. Install via Xposed manager
3. Configure per-app DPI:
   - Open App Settings
   - Select target app
   - Set custom DPI
   - Save and reboot

## Method 2: Direct System Property Modification

### Via build.prop (Traditional):
```bash
# With root shell
adb shell su -c "mount -o rw,remount /system"

# Add per-app density override
adb shell su -c "echo 'persist.vendor.app.density.<package_name>=<dpi_value>' >> /system/build.prop"

# Example for a specific app
adb shell su -c "echo 'persist.vendor.app.density.com.example.app=320' >> /system/build.prop"

# Remount read-only and reboot
adb shell su -c "mount -o ro,remount /system"
adb reboot
```

### Via property service (Dynamic):
```bash
# Set property dynamically (survives reboot with persist.)
adb shell su -c "setprop persist.app.density.<package_name> <dpi_value>"

# Example
adb shell su -c "setprop persist.app.density.com.example.app 320"
```

## Method 3: Activity Manager Overrides (Root)

```bash
# Force app into specific density mode
adb shell su -c "am display-density --user 0 override <package_name> <dpi_value>"

# Set app configuration overrides
adb shell su -c "cmd activity override-config <package_name> density=<dpi_value>"
```

## Method 4: Package Manager Manipulation

```bash
# Get current app info
adb shell su -c "dumpsys package <package_name> | grep density"

# Modify package settings
adb shell su -c "pm set-app-configuration <package_name> --density <dpi_value>"
```

## Method 5: Runtime Resource Injection

### Create overlay APK:
```bash
# Create resource overlay for specific app
# This requires creating an overlay APK that targets the app
# and overrides its density configuration
```

### Install overlay:
```bash
adb install -r overlay.apk
adb shell su -c "cmd overlay enable --user 0 <overlay_package>"
```

## Method 6: Direct Database Modification

```bash
# Access settings database directly
adb shell su -c "sqlite3 /data/system/users/0/settings_secure.db"

# Insert app-specific density
sqlite> INSERT INTO secure (name, value) VALUES ('app_density_<package_name>', '<dpi_value>');
sqlite> .exit

# Or via content provider with root
adb shell su -c "content insert --uri content://settings/secure --bind name:s:app_density_<package_name> --bind value:i:<dpi_value>"
```

## Method 7: Hook System Services (Advanced)

### Using Riru modules:
```bash
# Install Riru framework via Magisk
# Install Riru-AppDensity module (if available)
# Configure per-app settings
```

### Manual hooking:
```bash
# Create system service hook
adb shell su -c "echo '#!/system/bin/sh
# Hook density for specific app
if [ \"\$1\" = \"<package_name>\" ]; then
    setprop debug.app.density <dpi_value>
fi' > /system/bin/app_density_hook.sh"

adb shell su -c "chmod 755 /system/bin/app_density_hook.sh"
```

## Method 8: Modified Framework (Most Powerful)

### Patch services.jar:
```bash
# Pull framework
adb pull /system/framework/services.jar

# Decompile, modify WindowManagerService to support per-app density
# Recompile and push back

adb shell su -c "mount -o rw,remount /system"
adb push services.jar /system/framework/
adb shell su -c "chmod 644 /system/framework/services.jar"
adb reboot
```

## Practical Script for Geely Monjaro:

```bash
#!/system/bin/sh
# Save as: /data/local/tmp/set_app_dpi.sh

PACKAGE=$1
DPI=$2

# Method 1: Try property
setprop persist.vendor.app.density.$PACKAGE $DPI

# Method 2: Try settings database
content insert --uri content://settings/secure --bind name:s:app_density_$PACKAGE --bind value:i:$DPI

# Method 3: Try activity manager
am display-density override $PACKAGE $DPI

echo "Set $PACKAGE to $DPI DPI"
```

Usage:
```bash
adb shell su -c "sh /data/local/tmp/set_app_dpi.sh com.example.app 320"
```

## Most Likely to Work on Geely Monjaro:

1. **Xposed/EdXposed with App Settings** - Most reliable if framework installs
2. **Property-based methods** - Good compatibility
3. **Settings database modification** - Should work with root

## Important Notes:

- Always backup before modifying system files
- Some methods may require SELinux to be permissive
- GKUI may have additional protections that block some methods
- Test changes with non-critical apps first
- Some methods may not persist across reboots

## Recovery Commands:

```bash
# Remove all custom properties
adb shell su -c "find /data/property -name '*app.density*' -delete"

# Clear settings database entries
adb shell su -c "content delete --uri content://settings/secure --where \"name LIKE 'app_density_%'\""

# Reset to stock
adb shell su -c "setprop persist.vendor.app.density.reset 1"
adb reboot
```