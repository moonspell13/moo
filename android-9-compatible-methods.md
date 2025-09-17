# Android 9 Compatible Per-App DPI Methods (With Root)

## ✅ WORKS on Android 9:

### 1. **Xposed/EdXposed Framework**
```bash
# EdXposed works on Android 9
# Install via Magisk, then App Settings module
# Full per-app DPI control
```
**Status**: ✅ Fully compatible

### 2. **Automation (Tasker/MacroDroid)**
```bash
# Change system DPI when app launches
# Restore when app closes
```
**Status**: ✅ Works but affects all apps temporarily

### 3. **Direct APK Modification**
```bash
# Decompile, modify, recompile APK
# Add density qualifiers to resources
```
**Status**: ✅ Always works, permanent solution

### 4. **App Cloning Solutions**
- Island (✅ Works)
- Shelter (✅ Works)
- Parallel Space (✅ Works)
**Status**: ✅ Each clone can have different system DPI

### 5. **Build.prop Modifications**
```bash
# Adding properties to build.prop
adb shell su -c "echo 'persist.vendor.app.density.<package>=320' >> /system/build.prop"
```
**Status**: ⚠️ Properties are added but Android 9 doesn't read per-app density from here

### 6. **Settings Database**
```bash
# Write to settings
adb shell settings put secure display_density_forced 320
```
**Status**: ⚠️ Works for system-wide only, not per-app

### 7. **VirtualXposed**
```bash
# Run apps in virtual container
# No root needed for VirtualXposed itself
```
**Status**: ✅ Works on Android 9

### 8. **Memory Injection**
**Status**: ⚠️ Possible but very app-specific and unstable

## ❌ DOES NOT WORK on Android 9:

### 1. **Native Per-App DPI**
```bash
# am display-density (Android 10+)
# cmd display set-app-scale (Android 10+)
```
**Status**: ❌ Introduced in Android 10

### 2. **Virtual Display with Per-App Assignment**
```bash
# Creating virtual displays works
# But can't assign specific apps to them in Android 9
```
**Status**: ❌ Limited implementation in Android 9

### 3. **Runtime Resource Overlay (RRO)**
**Status**: ❌ Per-app RRO requires Android 10+

### 4. **Display Configuration Files**
**Status**: ❌ System doesn't read per-app configs in Android 9

### 5. **Window Manager Per-App Overrides**
**Status**: ❌ Not implemented in Android 9

## 🔧 PRACTICAL SOLUTIONS for Android 9:

### Option 1: EdXposed + App Settings (Best)
```bash
# 1. Install Magisk
# 2. Install Riru
# 3. Install EdXposed
# 4. Install App Settings module
# 5. Configure per-app DPI in App Settings
```

### Option 2: Automation Script
```bash
#!/system/bin/sh
# Save as /data/local/dpi_switcher.sh

APP_PACKAGE="com.example.app"
APP_DPI=320
NORMAL_DPI=360

while true; do
    FOCUSED=$(dumpsys window | grep mCurrentFocus | grep -o "$APP_PACKAGE")
    CURRENT_DPI=$(settings get secure display_density_forced)
    
    if [ "$FOCUSED" = "$APP_PACKAGE" ] && [ "$CURRENT_DPI" != "$APP_DPI" ]; then
        settings put secure display_density_forced $APP_DPI
    elif [ -z "$FOCUSED" ] && [ "$CURRENT_DPI" = "$APP_DPI" ]; then
        settings put secure display_density_forced $NORMAL_DPI
    fi
    
    sleep 2
done
```

### Option 3: Modified APK
```bash
# Most reliable permanent solution
apktool d app.apk
# Edit AndroidManifest.xml
# Add: android:largeScreens="false"
# Edit res/values/dimens.xml
# Modify density-specific resources
apktool b app -o modified.apk
```

### Option 4: App Cloning
```bash
# Install Island or Shelter
# Clone target app
# Run with different system DPI for each profile
```

## Summary for Geely Monjaro (Android 9):

**Best Options:**
1. **EdXposed + App Settings** - True per-app DPI
2. **Automation with Tasker** - Easy but affects all apps temporarily
3. **APK Modification** - Permanent but requires work per app
4. **App Cloning** - Good for a few specific apps

**Won't Work:**
- Native Android per-app DPI (Android 10+ only)
- Virtual display assignment
- Runtime resource overlays
- Most property-based methods

The reality is that Android 9 has very limited support for per-app DPI. Your best bet is either EdXposed or automation-based solutions.