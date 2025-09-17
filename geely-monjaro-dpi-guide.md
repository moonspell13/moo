# Changing DPI on Geely Monjaro Without WM Command

The Geely Monjaro (Xingyue L) runs an Android-based infotainment system with GKUI interface powered by ECARX E02 chip. Here are the methods that should work:

## Most Likely to Work:

### Method 1: Settings Database (Recommended)
```bash
# This should work as it's a more universal Android approach
adb shell settings put secure display_density_forced 360

# To reset
adb shell settings delete secure display_density_forced
```

### Method 2: Content Provider
```bash
# Alternative approach using content provider
adb shell content insert --uri content://settings/secure --bind name:s:display_density_forced --bind value:i:360
```

## Prerequisites for Geely Monjaro:

1. **Enable Developer Options:**
   - Go to Settings in the infotainment system
   - Find "About" or "System Information" 
   - Tap "Build Number" 7 times
   - Developer Options will be enabled

2. **Enable USB Debugging:**
   - Go to Settings > Developer Options
   - Enable "USB Debugging"
   - Connect via USB to your computer

3. **Verify Connection:**
   ```bash
   adb devices
   ```

## Specific Considerations for Geely Monjaro:

1. **System Restrictions:**
   - The GKUI system may have some restrictions on system modifications
   - Some commands might require additional permissions

2. **Safe DPI Values:**
   - Start with small changes (e.g., from default to 320 or 360)
   - The dual 12.3-inch screens work best with DPI values between 280-400

3. **If First Method Fails, Try:**
   ```bash
   # Try with global settings instead of secure
   adb shell settings put global display_density_forced 360
   
   # Or try system settings
   adb shell settings put system display_density_forced 360
   ```

## Recovery Options:

If something goes wrong:

1. **Reset via ADB:**
   ```bash
   adb shell settings delete secure display_density_forced
   adb shell settings delete global display_density_forced
   adb shell settings delete system display_density_forced
   ```

2. **Safe Mode:**
   - Turn off the infotainment system
   - Turn it back on while holding a specific button (varies by model)

3. **Factory Reset:**
   - Last resort: Settings > System > Reset Options

## Important Warnings:

- **Warranty:** Modifying system settings may affect your warranty
- **System Updates:** Changes might be reset after OTA updates
- **Navigation:** Be careful not to set DPI too high/low as it might affect navigation visibility
- **Backup:** Note your current DPI before changing:
  ```bash
  adb shell settings get secure display_density_forced
  ```

## Test Command:

Before making changes, test if your system accepts settings commands:
```bash
# Test read access
adb shell settings list secure | grep density
```

The settings database method (Method 1) is most likely to work on the Geely Monjaro as it's a standard Android approach that bypasses the wm command restriction.