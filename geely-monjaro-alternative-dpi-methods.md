# Alternative Per-App DPI Methods for Geely Monjaro (With Root)

Beyond the methods already discussed, here are additional creative approaches:

## 1. Automation-Based Solutions

### Tasker with Root Actions:
```bash
# Install Tasker and create profiles that:
# 1. Detect when specific app launches
# 2. Change system DPI temporarily
# 3. Restore DPI when app closes

# Tasker shell commands:
settings put secure display_density_forced 320
# Wait for app exit
settings put secure display_density_forced 360
```

### MacroDroid Alternative:
```bash
# Similar to Tasker but simpler
# Create macro: App Launch → Shell Script → Change DPI
# Create macro: App Close → Shell Script → Restore DPI
```

## 2. Virtual Display Method

### Create Virtual Display for App:
```bash
# Create secondary virtual display with different DPI
adb shell su -c "service call display 5 i32 1920 i32 1080 i32 320"

# Launch app on virtual display
adb shell su -c "am start --display 1 <package_name>/<activity_name>"
```

### Display Manager Manipulation:
```bash
# Hook into DisplayManager service
adb shell su -c "service call display_manager 15 i32 <display_id> i32 <dpi>"
```

## 3. Runtime Resource Injection

### Resource Overlay Without APK:
```bash
# Create runtime resource overlay
adb shell su -c "mkdir -p /data/resource-cache/<package_name>"
adb shell su -c "echo 'density=320' > /data/resource-cache/<package_name>/config.xml"

# Hook resource loading
adb shell su -c "setprop debug.resource.overlay /data/resource-cache/"
```

### Direct APK Modification:
```bash
# Pull APK
adb pull $(adb shell pm path <package_name> | cut -d: -f2) app.apk

# Decompile with apktool
apktool d app.apk

# Modify res/values/dimens.xml or AndroidManifest.xml
# Add: android:requiresSmallestWidthDp="320"

# Recompile and sign
apktool b app -o modified.apk
jarsigner -keystore debug.keystore modified.apk

# Install
adb install -r modified.apk
```

## 4. Display Configuration Override

### Per-App Display Config:
```bash
# Create display configuration file
adb shell su -c "mkdir -p /data/system/display_configs/"
adb shell su -c "echo '{
  \"package\": \"<package_name>\",
  \"density\": 320,
  \"size\": \"1080x1920\"
}' > /data/system/display_configs/<package_name>.json"

# Apply via system property
adb shell su -c "setprop persist.display.config.path /data/system/display_configs/"
```

## 5. Accessibility Service Abuse

### Custom Accessibility Service:
```java
// Create accessibility service that:
// 1. Detects app launch
// 2. Modifies WindowManager.LayoutParams
// 3. Forces different density

public void onAccessibilityEvent(AccessibilityEvent event) {
    if (event.getPackageName().equals("target.package")) {
        // Modify display metrics via reflection
    }
}
```

## 6. Reflection-Based Runtime Modification

### Hook Application Creation:
```bash
# Create init.d script (requires init.d support)
#!/system/bin/sh
# /system/etc/init.d/99app_dpi

# Hook app launch
while true; do
    CURRENT_APP=$(dumpsys activity | grep mFocusedApp | cut -d' ' -f6 | cut -d'/' -f1)
    if [ "$CURRENT_APP" = "<package_name>" ]; then
        setprop debug.app.current_density 320
    else
        setprop debug.app.current_density 360
    fi
    sleep 1
done &
```

## 7. Memory Injection (Advanced)

### Direct Memory Manipulation:
```bash
# Find app process
PID=$(adb shell su -c "pidof <package_name>")

# Inject density value into memory
adb shell su -c "echo -n -e '\x40\x01\x00\x00' | dd of=/proc/$PID/mem bs=1 seek=$((0xDENSITY_OFFSET)) conv=notrunc"
```

## 8. Custom ROM Features

### If using custom ROM:
- **Paranoid Android**: Built-in per-app DPI
- **Resurrection Remix**: Per-app configuration
- **LineageOS**: With custom patches

## 9. App Cloning with Modified DPI

### Clone App with Different Config:
```bash
# Use app cloning tools (Island, Shelter)
# Modify cloned app's configuration
# Each clone can have different DPI
```

## 10. Kernel-Level Solution

### Custom Kernel Module:
```c
// Create kernel module that intercepts
// display density calls for specific apps
static int app_density_override(void) {
    if (current->comm == "target_app") {
        return 320; // Override density
    }
    return original_density;
}
```

## 11. Graphics Driver Override

### GPU Configuration:
```bash
# Modify GPU scaling per app
adb shell su -c "echo '<package_name> scale=1.5' > /sys/class/graphics/fb0/app_scale"
```

## 12. Container/Sandbox Solutions

### Use VirtualXposed:
```bash
# Run app in virtual container with custom DPI
# No system modification needed
```

### Use VMOS or Similar:
- Virtual Android system within Android
- Set different DPI for virtual system

## Practical Combination Script:

```bash
#!/system/bin/sh
# Ultimate per-app DPI setter

PACKAGE=$1
DPI=$2

# Try all methods
echo "Setting $PACKAGE to $DPI DPI..."

# Method 1: Properties
setprop persist.vendor.app.density.$PACKAGE $DPI
setprop ro.app.density.$PACKAGE $DPI

# Method 2: Settings
content insert --uri content://settings/secure --bind name:s:app_density_$PACKAGE --bind value:i:$DPI

# Method 3: Display config
mkdir -p /data/local/dpi_configs/
echo "$DPI" > /data/local/dpi_configs/$PACKAGE

# Method 4: Runtime hook
echo "$PACKAGE:$DPI" >> /data/local/app_dpi_list

# Method 5: Accessibility trigger
am broadcast -a com.custom.SET_APP_DPI --es package $PACKAGE --ei dpi $DPI

echo "Done! Restart the app to apply changes."
```

## For Geely Monjaro Specifically:

Most viable alternatives:
1. **Tasker/MacroDroid automation** - Simple and effective
2. **App cloning** - Each clone has different settings
3. **APK modification** - Permanent solution
4. **Virtual display** - Clean separation

The automation approach using Tasker or MacroDroid is probably the most user-friendly alternative that doesn't require deep system modifications.