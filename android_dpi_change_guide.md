# Change App DPI on Android 9 with ADB (Without WM Command)

This guide provides multiple methods to change DPI (dots per inch) on Android 9 devices using ADB without relying on the `wm` (Window Manager) command.

## Prerequisites

1. **Enable Developer Options and USB Debugging:**
   - Go to **Settings** > **About phone**
   - Tap **Build number** 7 times until Developer Options are enabled
   - Navigate to **Settings** > **Developer options**
   - Enable **USB debugging**

2. **Install ADB on your computer:**
   - Download [Android SDK Platform Tools](https://developer.android.com/studio/releases/platform-tools)
   - Extract to a convenient location
   - Add to your system PATH (optional but recommended)

3. **Connect your device:**
   ```bash
   # Verify device connection
   adb devices
   ```

## Method 1: Using Settings Command (System-wide)

This method changes the display density for the entire system:

```bash
# Get current DPI value (backup)
adb shell getprop ro.sf.lcd_density

# Change DPI using settings command
adb shell settings put system display_density_forced [DPI_VALUE]

# Example: Set DPI to 320
adb shell settings put system display_density_forced 320

# Restart the device to apply changes
adb reboot
```

**To reset:**
```bash
adb shell settings delete system display_density_forced
adb reboot
```

## Method 2: Using App Ops (Per-App DPI Scaling)

This method allows changing DPI for specific applications:

```bash
# Grant permission to modify display density for a specific app
adb shell pm grant [PACKAGE_NAME] android.permission.WRITE_SECURE_SETTINGS

# Set app-specific DPI override permission
adb shell appops set [PACKAGE_NAME] OVERRIDE_DISPLAY_DENSITY allow

# Force stop and restart the app to apply changes
adb shell am force-stop [PACKAGE_NAME]
```

**Example for Chrome:**
```bash
adb shell pm grant com.android.chrome android.permission.WRITE_SECURE_SETTINGS
adb shell appops set com.android.chrome OVERRIDE_DISPLAY_DENSITY allow
adb shell am force-stop com.android.chrome
```

## Method 3: Using SetProp (Property-based)

This method modifies the LCD density property directly:

```bash
# Check current LCD density property
adb shell getprop ro.sf.lcd_density

# Set new LCD density (requires root or system-level access)
adb shell setprop ro.sf.lcd_density [DPI_VALUE]

# Example: Set DPI to 280
adb shell setprop ro.sf.lcd_density 280

# Restart surface flinger to apply changes
adb shell stop
adb shell start
```

**Note:** This method may require root access on some devices.

## Method 4: Using Secure Settings (Alternative)

For devices that support it, you can use secure settings:

```bash
# Set display density in secure settings
adb shell settings put secure display_density_forced [DPI_VALUE]

# Example: Set DPI to 240
adb shell settings put secure display_density_forced 240

# Restart the device
adb reboot
```

## Method 5: Disable API Blacklist (For Android 9+)

Android 9 introduced API blacklisting. To bypass this for DPI changes:

```bash
# Disable hidden API blacklist
adb shell settings put global hidden_api_policy_pre_p_apps 1
adb shell settings put global hidden_api_policy_p_apps 1

# Then use any of the above methods
adb shell settings put system display_density_forced [DPI_VALUE]
adb reboot
```

## Common DPI Values

| Device Type | Recommended DPI |
|-------------|----------------|
| Phone (Small) | 160-240 |
| Phone (Medium) | 240-320 |
| Phone (Large) | 320-480 |
| Tablet (Small) | 160-213 |
| Tablet (Large) | 160-240 |

## Troubleshooting

### If display becomes unusable:
```bash
# Reset all display settings
adb shell settings delete system display_density_forced
adb shell settings delete secure display_density_forced
adb reboot
```

### If ADB becomes unresponsive:
```bash
# Restart ADB server
adb kill-server
adb start-server
adb devices
```

### Check current settings:
```bash
# View current display settings
adb shell dumpsys display | grep -i density
adb shell getprop | grep -i density
```

## Safety Tips

1. **Always backup current DPI value** before making changes
2. **Test with small incremental changes** (±20-40 DPI)
3. **Have a way to reset** if the display becomes unusable
4. **Reboot after changes** for full effect
5. **Some apps may not respond well** to DPI changes

## Finding Package Names

To find the package name of an app:
```bash
# List all installed packages
adb shell pm list packages

# Find specific app (example: Chrome)
adb shell pm list packages | grep chrome

# Get package name of currently running app
adb shell dumpsys window windows | grep -E 'mCurrentFocus'
```

## Advanced: Batch Script

Save this as a batch script for easy DPI changes:

```bash
#!/bin/bash
# android_dpi_changer.sh

if [ $# -eq 0 ]; then
    echo "Usage: $0 <DPI_VALUE>"
    echo "Example: $0 320"
    exit 1
fi

DPI_VALUE=$1

echo "Backing up current DPI..."
CURRENT_DPI=$(adb shell getprop ro.sf.lcd_density)
echo "Current DPI: $CURRENT_DPI"

echo "Setting new DPI to: $DPI_VALUE"
adb shell settings put system display_density_forced $DPI_VALUE

echo "Rebooting device..."
adb reboot

echo "DPI change complete!"
echo "To restore original DPI, run:"
echo "adb shell settings delete system display_density_forced && adb reboot"
```

Make it executable:
```bash
chmod +x android_dpi_changer.sh
./android_dpi_changer.sh 320
```