# Changing DPI for Single App on Geely Monjaro

Unfortunately, changing DPI for individual apps on Android (especially Android 9 and automotive systems like GKUI) is much more limited than system-wide DPI changes. Here are the available options:

## Method 1: App Scaling (Android 10+ Feature)
**Note:** This likely won't work on Geely Monjaro if it runs Android 9
```bash
# This command is for Android 10+
adb shell cmd display set-app-scale <package_name> <scale_factor>
```

## Method 2: Using Accessibility Features
Some Android systems allow per-app display scaling through accessibility:

1. **Check if available:**
   ```bash
   adb shell settings list secure | grep magnification
   ```

2. **Enable magnification for specific app:**
   ```bash
   # This is system-dependent and may not work
   adb shell settings put secure accessibility_display_magnification_enabled 1
   ```

## Method 3: App Compatibility Mode (Limited)
Force an app into compatibility mode which may change its rendering:

```bash
# Get package name first
adb shell pm list packages | grep <app_name>

# Try to force compatibility mode
adb shell am compat enable FORCE_NON_RESIZE_APP <package_name>
adb shell am compat enable FORCE_RESIZE_APP <package_name>
```

## Method 4: Third-Party Solutions

### Option A: App Settings Xposed Module (Requires Root)
- Not viable for Geely Monjaro without root

### Option B: Resolution Changer App with Per-App Profiles
1. Install "Resolution Changer - Uses ADB"
2. Grant permissions:
   ```bash
   adb shell pm grant com.draco.resolutionchanger android.permission.WRITE_SECURE_SETTINGS
   ```
3. Check if app supports per-app profiles

## Method 5: Manifest Modification (Complex)
For apps you can modify:

```bash
# Extract APK
adb pull $(adb shell pm path <package_name> | cut -d: -f2) app.apk

# Modify AndroidManifest.xml to include:
# android:largeScreens="false"
# android:normalScreens="false"

# Reinstall modified APK
```

## Workarounds for Geely Monjaro:

### 1. Display Size Adjustment (Affects all apps)
```bash
# Temporarily change display size when using specific app
adb shell settings put secure display_size_forced 1920x1080

# Reset when done
adb shell settings delete secure display_size_forced
```

### 2. Font Size Override
```bash
# Change font scale (affects all apps but less intrusive)
adb shell settings put system font_scale 1.3
```

### 3. Developer Options Override
```bash
# Force activities to be resizable (may help with some apps)
adb shell settings put global force_resizable_activities 1
```

## Reality Check for Geely Monjaro:

**Unfortunately, true per-app DPI changes are NOT natively supported on:**
- Android 9 (which Monjaro likely runs)
- GKUI customized Android systems
- Most automotive infotainment systems

**Your best options are:**
1. **System-wide DPI change** (as discussed earlier)
2. **Font scale adjustment** (less intrusive)
3. **Contact app developer** to add in-app scaling options
4. **Use Android Auto/CarPlay** if the app supports it (better scaling)

## Script for Quick Toggle:

Create a script to quickly switch DPI when using specific apps:

```bash
#!/bin/bash
# save_as: toggle_dpi.sh

NORMAL_DPI=360
APP_DPI=320
CURRENT=$(adb shell settings get secure display_density_forced)

if [ "$CURRENT" == "$APP_DPI" ]; then
    adb shell settings put secure display_density_forced $NORMAL_DPI
    echo "Switched to normal DPI: $NORMAL_DPI"
else
    adb shell settings put secure display_density_forced $APP_DPI
    echo "Switched to app DPI: $APP_DPI"
fi
```

## Bottom Line:

True per-app DPI control is not available on Android 9 or GKUI systems without root access or custom ROMs. The best approach for Geely Monjaro is to:
1. Use system-wide DPI that works best for most apps
2. Contact problematic app developers for built-in scaling options
3. Use quick toggle scripts to switch DPI when needed