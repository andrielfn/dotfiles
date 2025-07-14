#!/usr/bin/env bash

# macOS defaults installer
# This script configures macOS system preferences for optimal development experience
# Optimized for macOS Sonoma (14.x)
#
# Note: Some commands that worked in earlier macOS versions have been deprecated:
# - spctl --master-disable (Gatekeeper) - removed in Sequoia, limited in Sonoma
# - tmutil disablelocal - deprecated since High Sierra, ineffective on APFS
# - Some systemsetup commands may require manual configuration in System Settings

source "$(dirname "$0")/../scripts/utils.sh"

# Check if running on macOS
if ! is_macos; then
  print_error "This script is only for macOS"
  exit 1
fi

configure_general_ui() {
  print_header "Configuring General UI Settings"

  # Enable dark mode
  print_step "Enabling dark mode..."
  defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

  # Enable auto-hide menu bar
  print_step "Auto-hiding menu bar..."
  defaults write NSGlobalDomain _HIHideMenuBar -bool true

  # Disable the "Are you sure you want to open this application?" dialog
  print_step "Disabling app quarantine dialog..."
  defaults write com.apple.LaunchServices LSQuarantine -bool false

  # Disable automatic termination of inactive apps
  print_step "Disabling automatic app termination..."
  defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

  # Disable the crash reporter
  print_step "Disabling crash reporter..."
  defaults write com.apple.CrashReporter DialogType -string "none"

  # Expand save panel by default
  print_step "Expanding save panel by default..."
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

  # Expand print panel by default
  print_step "Expanding print panel by default..."
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  print_success "General UI settings configured"
}

configure_dock() {
  print_header "Configuring Dock"

  # Set dock to auto-hide
  print_step "Setting dock to auto-hide..."
  defaults write com.apple.dock autohide -bool true

  # Remove delay when auto-hiding dock
  print_step "Removing dock auto-hide delay..."
  defaults write com.apple.dock autohide-delay -float 0

  # Speed up dock animation
  print_step "Speeding up dock animation..."
  defaults write com.apple.dock autohide-time-modifier -float 0.5

  # Set dock size
  print_step "Setting dock size..."
  defaults write com.apple.dock tilesize -int 48

  # Don't show recent applications in dock
  print_step "Hiding recent applications in dock..."
  defaults write com.apple.dock show-recents -bool false

  # Remove all default apps from dock
  print_step "Clearing default dock apps..."
  defaults write com.apple.dock persistent-apps -array

  print_success "Dock configured"
}

configure_finder() {
  print_header "Configuring Finder"

  # Show hidden files
  print_step "Showing hidden files..."
  defaults write com.apple.finder AppleShowAllFiles -bool true

  # Show file extensions
  print_step "Showing file extensions..."
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Show status bar
  print_step "Showing status bar..."
  defaults write com.apple.finder ShowStatusBar -bool true

  # Show path bar
  print_step "Showing path bar..."
  defaults write com.apple.finder ShowPathbar -bool true

  # Display full POSIX path as Finder window title
  print_step "Showing full path in title..."
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

  # Keep folders on top when sorting by name
  print_step "Keeping folders on top..."
  defaults write com.apple.finder _FXSortFoldersFirst -bool true

  # Search current folder by default
  print_step "Setting search scope to current folder..."
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  # Disable warning when changing file extensions
  print_step "Disabling extension change warning..."
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  # Disable warning when emptying trash
  print_step "Disabling trash warning..."
  defaults write com.apple.finder WarnOnEmptyTrash -bool false

  # Use column view by default
  print_step "Setting default view to column view..."
  defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

  print_success "Finder configured"
}

configure_keyboard() {
  print_header "Configuring Keyboard"

  # Set fast key repeat rate
  print_step "Setting fast key repeat..."
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15

  # Disable automatic capitalization
  print_step "Disabling automatic capitalization..."
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

  # Disable smart dashes
  print_step "Disabling smart dashes..."
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  # Disable automatic period substitution
  print_step "Disabling automatic period substitution..."
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

  # Disable smart quotes
  print_step "Disabling smart quotes..."
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

  # Disable auto-correct
  print_step "Disabling auto-correct..."
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  # Enable full keyboard access for all controls
  print_step "Enabling full keyboard access..."
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  print_success "Keyboard configured"
}

configure_trackpad() {
  print_header "Configuring Trackpad"

  # Enable tap to click
  print_step "Enabling tap to click..."
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # Enable three finger drag
  print_step "Enabling three finger drag..."
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

  # Enable secondary click
  print_step "Enabling secondary click..."
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

  print_success "Trackpad configured"
}

configure_screenshots() {
  print_header "Configuring Screenshots"

  # Create screenshots directory
  mkdir -p "$HOME/Screenshots"

  # Save screenshots to ~/Screenshots
  print_step "Setting screenshots location..."
  defaults write com.apple.screencapture location -string "$HOME/Screenshots"

  # Save screenshots in PNG format
  print_step "Setting screenshot format to PNG..."
  defaults write com.apple.screencapture type -string "png"

  # Disable shadow in screenshots
  print_step "Disabling screenshot shadows..."
  defaults write com.apple.screencapture disable-shadow -bool true

  print_success "Screenshots configured"
}

configure_security() {
  print_header "Configuring Security"

  # Require password immediately after sleep or screen saver begins
  print_step "Requiring password after sleep..."
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  # Enable firewall
  print_step "Enabling firewall..."
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

  # Enable stealth mode
  print_step "Enabling stealth mode..."
  sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

  # Note: Gatekeeper disable command removed in macOS Sequoia, limited in Sonoma
  # print_step "Configuring Gatekeeper..."
  # sudo spctl --master-disable  # Removed: No longer works in macOS Sequoia and later

  print_success "Security configured"
}

configure_terminal() {
  print_header "Configuring Terminal"

  # Set Terminal to use basic theme
  print_step "Configuring Terminal theme..."
  defaults write com.apple.Terminal "Default Window Settings" -string "Basic"
  defaults write com.apple.Terminal "Startup Window Settings" -string "Basic"

  # Set scrollback buffer
  print_step "Setting Terminal scrollback buffer..."
  defaults write com.apple.Terminal ScrollbackLines -int 10000

  # Disable audible bell
  print_step "Disabling Terminal bell..."
  defaults write com.apple.Terminal AudibleBell -bool false

  # Enable UTF-8 support
  print_step "Enabling UTF-8 support..."
  defaults write com.apple.Terminal StringEncodings -array 4

  print_success "Terminal configured"
}

configure_developer_tools() {
  print_header "Configuring Developer Tools"

  # Install Xcode command line tools
  print_step "Installing Xcode command line tools..."
  if ! xcode-select --print-path &>/dev/null; then
    xcode-select --install
    print_info "Please complete the Xcode command line tools installation"
    print_info "Press any key to continue after installation is complete..."
    read -n 1
  fi

  # Note: DevToolsSecurity and Gatekeeper commands have limited functionality in Sonoma
  # Enable developer mode (may require manual approval in System Settings > Privacy & Security)
  print_step "Attempting to enable developer mode..."
  sudo DevToolsSecurity -enable 2>/dev/null || print_warning "Developer mode may require manual approval in System Settings"

  # Note: spctl --master-disable removed in Sequoia, limited in Sonoma
  # print_step "Configuring Gatekeeper..."
  # sudo spctl --master-disable  # Removed: No longer works in macOS Sequoia and later

  print_success "Developer tools configured"
}

configure_time_machine() {
  print_header "Configuring Time Machine"

  # Note: tmutil disablelocal is deprecated since macOS High Sierra/Mojave
  # and is ineffective on APFS-based systems (Sonoma uses APFS)
  # print_step "Disabling local Time Machine snapshots..."
  # sudo tmutil disablelocal  # Removed: Deprecated since macOS High Sierra/Mojave and ineffective in APFS-based systems

  # Prevent Time Machine from prompting to use new hard drives as backup volume
  print_step "Preventing Time Machine prompts..."
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

  # Disable Time Machine auto backup (optional)
  # Uncomment the next line if you want to disable automatic Time Machine backups
  # sudo tmutil disable

  print_success "Time Machine configured"
}

restart_affected_apps() {
  print_header "Restarting Affected Applications"

  # Restart affected applications
  for app in "Activity Monitor" "Dock" "Finder" "SystemUIServer"; do
    print_step "Restarting $app..."
    killall "$app" &>/dev/null || true
  done

  print_success "Applications restarted"
}

main() {
  print_header "macOS Configuration Script"
  print_info "This script will configure macOS for optimal development experience"
  print_info "Optimized for macOS Sonoma (14.x)"
  print_warning "Some changes require administrator privileges"

  ask_for_confirmation "Do you want to continue with macOS configuration?"
  if ! answer_is_yes; then
    print_warning "macOS configuration cancelled"
    exit 0
  fi

  # Ask for sudo password upfront
  sudo -v

  # Keep sudo alive
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &

  # Run configuration functions
  configure_general_ui
  configure_dock
  configure_finder
  configure_keyboard
  configure_trackpad
  configure_screenshots
  configure_security
  configure_terminal
  configure_developer_tools
  configure_time_machine
  restart_affected_apps

  print_success "macOS configuration complete!"
  print_info "Some changes may require a restart to take effect"

  ask_for_confirmation "Would you like to restart now?"
  if answer_is_yes; then
    print_info "Restarting in 5 seconds..."
    sleep 5
    sudo shutdown -r now
  fi
}

main "$@"
