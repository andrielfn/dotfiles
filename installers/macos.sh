#!/usr/bin/env bash

# macOS defaults installer
# This script configures macOS system preferences for optimal development experience.
# Verified against macOS Sequoia (15.x) and Tahoe (26.x).
#
# Most `defaults` domains here are stable across versions; the few genuine
# per-version differences are handled with `$os_major` guards rather than
# separate per-version files (see configure_appearance for Tahoe-only keys).
#
# Note: Some commands that worked in earlier macOS versions have been deprecated:
# - spctl --master-disable (Gatekeeper) - removed in Sequoia, limited in Sonoma
# - tmutil disablelocal - deprecated since High Sierra, ineffective on APFS
# - com.apple.alf plist writes - unreliable since Sequoia; use socketfilterfw
# - Some systemsetup commands may require manual configuration in System Settings

source "$(dirname "$0")/../scripts/utils.sh"

# Check if running on macOS
if ! is_macos; then
  print_error "This script is only for macOS"
  exit 1
fi

# Major OS version (15 = Sequoia, 26 = Tahoe). Used to guard version-specific keys.
os_major="$(get_os_version | cut -d. -f1)"

# Warn on versions we haven't verified against, but continue: the shared
# defaults domains are stable, so only version-guarded blocks are at risk.
if [[ "$os_major" -lt 15 || "$os_major" -gt 26 ]] 2>/dev/null; then
  print_warning "Untested macOS version ($(get_os_version)); verified on Sequoia (15) and Tahoe (26)."
  print_warning "Shared settings should apply; version-guarded blocks may be skipped."
fi

configure_general_ui() {
  print_header "Configuring General UI Settings"

  # Enable dark mode
  print_step "Enabling dark mode..."
  defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

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

  # Save new documents to disk (not iCloud) by default
  print_step "Defaulting save dialogs to local disk..."
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

  # Don't auto-open Photos when a device (iPhone/camera) is connected
  print_step "Disabling Photos auto-open on device connect..."
  defaults write com.apple.ImageCapture disableHotPlug -bool true

  print_success "General UI settings configured"
}

configure_appearance() {
  # Tahoe (macOS 26+) only: tone down the Liquid Glass redesign.
  # These are the only verified, scriptable Tahoe-specific keys — the menu bar
  # background, glass tint, Spotlight clipboard, and Control Center layout are
  # GUI-only with no defaults keys. Both keys live in com.apple.universalaccess
  # and typically require a logout/restart to fully take effect.
  if [[ "$os_major" -lt 26 ]] 2>/dev/null; then
    return 0
  fi

  print_header "Configuring Appearance (Tahoe)"

  # Reduce transparency: opaque menu bar, Dock, and Control Center
  print_step "Reducing Liquid Glass transparency..."
  defaults write com.apple.universalaccess reduceTransparency -bool true

  # Reduce motion: snappier, less animated window/space transitions
  print_step "Reducing motion..."
  defaults write com.apple.universalaccess reduceMotion -bool true

  print_success "Appearance configured (log out/in to fully apply)"
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

  # Keep Spaces in a fixed order (don't rearrange by most-recent use)
  print_step "Disabling automatic Space rearranging..."
  defaults write com.apple.dock mru-spaces -bool false

  # Remove all default apps from dock
  print_step "Clearing default dock apps..."
  defaults write com.apple.dock persistent-apps -array

  print_success "Dock configured"
}

configure_finder() {
  print_header "Configuring Finder"

  # Open new Finder windows to Home instead of Recents
  print_step "Setting new Finder windows to open at Home..."
  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

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

  # Set the fastest practical key repeat.
  # These go below the System Settings sliders' minimums (KeyRepeat 2 /
  # InitialKeyRepeat 15). KeyRepeat 1 is the fastest usable rate (0 is often
  # too fast/glitchy); InitialKeyRepeat 10 shortens the delay before repeating.
  print_step "Setting fastest key repeat..."
  defaults write NSGlobalDomain KeyRepeat -int 1
  defaults write NSGlobalDomain InitialKeyRepeat -int 10

  # Disable press-and-hold accent popup so holding a key repeats it
  # (needed for Vim / editor motions)
  print_step "Disabling press-and-hold accent popup..."
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

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

  # Enable tap to click.
  # The AppleBluetoothMultitouch.trackpad domain is unreliable from a plain
  # `defaults write` and often won't take on a built-in trackpad until it's
  # also written to the per-host (ByHost) domain, so we write both.
  print_step "Enabling tap to click..."
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
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

  # Disable the floating thumbnail (screenshot is saved/paste-ready immediately)
  print_step "Disabling screenshot floating thumbnail..."
  defaults write com.apple.screencapture show-thumbnail -bool false

  # Omit the date/time from screenshot filenames
  print_step "Removing date from screenshot filenames..."
  defaults write com.apple.screencapture include-date -bool false

  print_success "Screenshots configured"
}

configure_desktop_services() {
  print_header "Configuring Desktop Services"

  # Don't write .DS_Store files on network or USB volumes
  # (keeps them out of shared drives and git repos)
  print_step "Preventing .DS_Store on network volumes..."
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

  print_step "Preventing .DS_Store on USB volumes..."
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  print_success "Desktop services configured"
}

configure_security() {
  print_header "Configuring Security"

  # Require password immediately after sleep or screen saver begins
  print_step "Requiring password after sleep..."
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  # Enable firewall via socketfilterfw (the com.apple.alf plist-write approach
  # is unreliable since Sequoia). socketfilterfw is still valid on Tahoe.
  local fw="/usr/libexec/ApplicationFirewall/socketfilterfw"

  print_step "Enabling firewall..."
  if sudo "$fw" --setglobalstate on; then
    print_step "Enabling stealth mode..."
    sudo "$fw" --setstealthmode on ||
      print_warning "Could not enable stealth mode; enable it in System Settings > Network > Firewall."
  else
    print_warning "Could not enable the firewall via socketfilterfw; enable it manually in System Settings > Network > Firewall."
  fi

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
  print_info "Detected macOS $(get_os_version) (verified on Sequoia 15.x and Tahoe 26.x)"
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
  configure_appearance
  configure_dock
  configure_finder
  configure_keyboard
  configure_trackpad
  configure_screenshots
  configure_desktop_services
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
