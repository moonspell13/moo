#!/bin/bash
# Android DPI Changer Script
# Changes DPI on Android 9+ devices without using wm command
# Author: AI Assistant
# Usage: ./android_dpi_changer.sh [DPI_VALUE] [METHOD]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Function to check if device is connected
check_device() {
    print_info "Checking device connection..."
    if ! adb devices | grep -q "device$"; then
        print_error "No device connected or device not authorized"
        print_info "Please ensure:"
        print_info "1. USB debugging is enabled"
        print_info "2. Device is connected via USB"
        print_info "3. You've authorized the computer on your device"
        exit 1
    fi
    print_success "Device connected successfully"
}

# Function to backup current DPI
backup_current_dpi() {
    print_info "Backing up current DPI settings..."
    
    # Get current LCD density property
    CURRENT_LCD_DENSITY=$(adb shell getprop ro.sf.lcd_density 2>/dev/null)
    
    # Get current system display density setting
    CURRENT_SYSTEM_DENSITY=$(adb shell settings get system display_density_forced 2>/dev/null)
    
    # Get current secure display density setting
    CURRENT_SECURE_DENSITY=$(adb shell settings get secure display_density_forced 2>/dev/null)
    
    echo "Current LCD Density Property: ${CURRENT_LCD_DENSITY:-"Not set"}"
    echo "Current System Display Density: ${CURRENT_SYSTEM_DENSITY:-"Not set"}"
    echo "Current Secure Display Density: ${CURRENT_SECURE_DENSITY:-"Not set"}"
    
    # Save to backup file
    echo "# DPI Backup - $(date)" > dpi_backup.txt
    echo "LCD_DENSITY=$CURRENT_LCD_DENSITY" >> dpi_backup.txt
    echo "SYSTEM_DENSITY=$CURRENT_SYSTEM_DENSITY" >> dpi_backup.txt
    echo "SECURE_DENSITY=$CURRENT_SECURE_DENSITY" >> dpi_backup.txt
    
    print_success "Backup saved to dpi_backup.txt"
}

# Function to restore DPI from backup
restore_dpi() {
    if [ ! -f "dpi_backup.txt" ]; then
        print_error "No backup file found (dpi_backup.txt)"
        print_info "Attempting to reset to default settings..."
        adb shell settings delete system display_density_forced
        adb shell settings delete secure display_density_forced
        print_info "Rebooting device..."
        adb reboot
        return
    fi
    
    print_info "Restoring DPI from backup..."
    source dpi_backup.txt
    
    if [ "$SYSTEM_DENSITY" != "null" ] && [ -n "$SYSTEM_DENSITY" ]; then
        adb shell settings put system display_density_forced "$SYSTEM_DENSITY"
    else
        adb shell settings delete system display_density_forced
    fi
    
    if [ "$SECURE_DENSITY" != "null" ] && [ -n "$SECURE_DENSITY" ]; then
        adb shell settings put secure display_density_forced "$SECURE_DENSITY"
    else
        adb shell settings delete secure display_density_forced
    fi
    
    print_success "DPI settings restored from backup"
    print_info "Rebooting device..."
    adb reboot
}

# Function to change DPI using settings method
change_dpi_settings() {
    local dpi_value=$1
    print_info "Changing DPI to $dpi_value using settings method..."
    
    # Disable API blacklist for Android 9+
    adb shell settings put global hidden_api_policy_pre_p_apps 1 2>/dev/null
    adb shell settings put global hidden_api_policy_p_apps 1 2>/dev/null
    
    # Set the new DPI
    adb shell settings put system display_density_forced "$dpi_value"
    
    print_success "DPI changed to $dpi_value"
    print_info "Rebooting device to apply changes..."
    adb reboot
}

# Function to change DPI using secure settings method
change_dpi_secure() {
    local dpi_value=$1
    print_info "Changing DPI to $dpi_value using secure settings method..."
    
    adb shell settings put secure display_density_forced "$dpi_value"
    
    print_success "DPI changed to $dpi_value"
    print_info "Rebooting device to apply changes..."
    adb reboot
}

# Function to change DPI using setprop method
change_dpi_setprop() {
    local dpi_value=$1
    print_info "Changing DPI to $dpi_value using setprop method..."
    print_warning "This method may require root access"
    
    adb shell setprop ro.sf.lcd_density "$dpi_value"
    
    print_info "Restarting surface flinger..."
    adb shell stop 2>/dev/null
    sleep 2
    adb shell start 2>/dev/null
    
    print_success "DPI changed to $dpi_value using setprop"
}

# Function to set per-app DPI scaling
set_app_dpi_scaling() {
    local package_name=$1
    print_info "Setting up DPI scaling for app: $package_name"
    
    # Grant permission
    adb shell pm grant "$package_name" android.permission.WRITE_SECURE_SETTINGS 2>/dev/null
    
    # Set app ops permission
    adb shell appops set "$package_name" OVERRIDE_DISPLAY_DENSITY allow
    
    # Force stop the app
    adb shell am force-stop "$package_name"
    
    print_success "DPI scaling enabled for $package_name"
    print_info "You can now launch the app to see the changes"
}

# Function to show usage
show_usage() {
    echo "Android DPI Changer Script"
    echo "=========================="
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -d, --dpi DPI_VALUE        Set DPI to specified value (120-640)"
    echo "  -m, --method METHOD        Choose method: settings, secure, setprop"
    echo "  -a, --app PACKAGE_NAME     Enable DPI scaling for specific app"
    echo "  -r, --restore              Restore DPI from backup"
    echo "  -b, --backup               Backup current DPI settings only"
    echo "  -i, --info                 Show current DPI information"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -d 320                  # Set DPI to 320 using default method"
    echo "  $0 -d 280 -m secure        # Set DPI to 280 using secure method"
    echo "  $0 -a com.android.chrome   # Enable DPI scaling for Chrome"
    echo "  $0 -r                      # Restore DPI from backup"
    echo "  $0 -i                      # Show current DPI info"
    echo ""
    echo "Common DPI Values:"
    echo "  160 - Low density (ldpi)"
    echo "  240 - Medium density (mdpi)"
    echo "  320 - High density (hdpi)"
    echo "  480 - Extra high density (xhdpi)"
    echo "  640 - Extra extra high density (xxhdpi)"
}

# Function to show current DPI info
show_dpi_info() {
    print_info "Current DPI Information:"
    echo "========================"
    
    # LCD Density Property
    LCD_DENSITY=$(adb shell getprop ro.sf.lcd_density 2>/dev/null)
    echo "LCD Density Property: ${LCD_DENSITY:-"Not set"}"
    
    # System Display Density
    SYSTEM_DENSITY=$(adb shell settings get system display_density_forced 2>/dev/null)
    echo "System Display Density: ${SYSTEM_DENSITY:-"Not set"}"
    
    # Secure Display Density
    SECURE_DENSITY=$(adb shell settings get secure display_density_forced 2>/dev/null)
    echo "Secure Display Density: ${SECURE_DENSITY:-"Not set"}"
    
    # Display metrics
    echo ""
    print_info "Display Metrics:"
    adb shell dumpsys display | grep -E "(density|dpi)" 2>/dev/null || echo "Could not retrieve display metrics"
}

# Main script logic
main() {
    # Check if no arguments provided
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dpi)
                DPI_VALUE="$2"
                shift 2
                ;;
            -m|--method)
                METHOD="$2"
                shift 2
                ;;
            -a|--app)
                APP_PACKAGE="$2"
                shift 2
                ;;
            -r|--restore)
                RESTORE_MODE=true
                shift
                ;;
            -b|--backup)
                BACKUP_ONLY=true
                shift
                ;;
            -i|--info)
                INFO_ONLY=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check device connection
    check_device
    
    # Handle different modes
    if [ "$INFO_ONLY" = true ]; then
        show_dpi_info
        exit 0
    fi
    
    if [ "$BACKUP_ONLY" = true ]; then
        backup_current_dpi
        exit 0
    fi
    
    if [ "$RESTORE_MODE" = true ]; then
        restore_dpi
        exit 0
    fi
    
    if [ -n "$APP_PACKAGE" ]; then
        set_app_dpi_scaling "$APP_PACKAGE"
        exit 0
    fi
    
    if [ -n "$DPI_VALUE" ]; then
        # Validate DPI value
        if ! [[ "$DPI_VALUE" =~ ^[0-9]+$ ]] || [ "$DPI_VALUE" -lt 120 ] || [ "$DPI_VALUE" -gt 640 ]; then
            print_error "Invalid DPI value. Please use a number between 120 and 640."
            exit 1
        fi
        
        # Backup current settings
        backup_current_dpi
        
        # Apply DPI change based on method
        case "${METHOD:-settings}" in
            settings)
                change_dpi_settings "$DPI_VALUE"
                ;;
            secure)
                change_dpi_secure "$DPI_VALUE"
                ;;
            setprop)
                change_dpi_setprop "$DPI_VALUE"
                ;;
            *)
                print_error "Invalid method. Use: settings, secure, or setprop"
                exit 1
                ;;
        esac
        
        print_success "DPI change operation completed!"
        print_info "If the display becomes unusable, run: $0 -r"
        exit 0
    fi
    
    print_error "No valid action specified"
    show_usage
    exit 1
}

# Run main function with all arguments
main "$@"