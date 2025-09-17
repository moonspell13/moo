# How to Change App DPI on Android 9 with ADB (Without WM Command)

Since you want to change DPI without using the `wm` (window manager) command, here are alternative methods:

## Method 1: Using Settings Database

While the `wm` command is the most common way, you can try modifying the settings database directly:

```bash
# To change the global display density
adb shell settings put secure display_density_forced <DPI_VALUE>

# Example: Set DPI to 360
adb shell settings put secure display_density_forced 360

# To reset to default
adb shell settings delete secure display_density_forced
```

## Method 2: Using Content Provider

```bash
# Change display density via content provider
adb shell content insert --uri content://settings/secure --bind name:s:display_density_forced --bind value:i:<DPI_VALUE>

# Example: Set DPI to 360
adb shell content insert --uri content://settings/secure --bind name:s:display_density_forced --bind value:i:360
```

## Method 3: Using Third-Party App with ADB Permissions

1. **Install "Resolution Changer — Uses ADB" app** from Google Play Store

2. **Enable USB Debugging:**
   - Go to Settings > About phone
   - Tap "Build number" 7 times to enable Developer options
   - Go to Settings > Developer options
   - Enable "USB debugging"

3. **Grant permissions via ADB:**
   ```bash
   adb shell pm grant com.draco.resolutionchanger android.permission.WRITE_SECURE_SETTINGS
   ```

4. **Use the app to change DPI** without needing to use the wm command directly

## Method 4: Direct Property Modification (Root Required)

If your device is rooted:

```bash
# Modify build.prop (requires root)
adb shell "su -c 'sed -i \"s/ro.sf.lcd_density=.*/ro.sf.lcd_density=<DPI_VALUE>/\" /system/build.prop'"

# Then reboot
adb reboot
```

## Method 5: Using Activity Manager for Per-App DPI (Android 9+)

For changing DPI of specific apps:

```bash
# Set per-app density
adb shell am display-density <DPI_VALUE>

# Example for a specific app
adb shell am start -n <package_name>/<activity_name> --display-density <DPI_VALUE>
```

## Important Notes:

1. **DPI Values:** Common DPI values are:
   - ldpi: 120
   - mdpi: 160
   - hdpi: 240
   - xhdpi: 320
   - xxhdpi: 480
   - xxxhdpi: 640

2. **Check Current DPI:**
   ```bash
   adb shell getprop ro.sf.lcd_density
   ```

3. **If Something Goes Wrong:**
   - Boot into safe mode
   - Use recovery mode to reset settings
   - As a last resort, factory reset

4. **Limitations:**
   - Some methods may require a reboot to take effect
   - Not all methods work on all Android 9 devices due to manufacturer customizations
   - Some methods may only affect certain UI elements

## Verification

After changing DPI, verify the change:

```bash
# Check current density setting
adb shell settings get secure display_density_forced

# Or check system property
adb shell getprop ro.sf.lcd_density
```

Remember that changing DPI can affect app layouts and some apps may not display correctly at non-standard DPI values.