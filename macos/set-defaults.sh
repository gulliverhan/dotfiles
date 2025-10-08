# Sets reasonable macOS defaults.
#
# Or, in other words, set shit how I like in macOS.
#
# The original idea (and a couple settings) were grabbed from:
#   https://github.com/mathiasbynens/dotfiles/blob/master/.macos
#
# Run ./set-defaults.sh and you'll be good to go.

# Disable press-and-hold for keys in favor of key repeat.
defaults write -g ApplePressAndHoldEnabled -bool false

# Use AirDrop over every interface. srsly this should be a default.
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

# Always open everything in Finder's list view. This is important.
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

# Show the ~/Library folder.
chflags nohidden ~/Library

# Set a really fast key repeat.
defaults write NSGlobalDomain KeyRepeat -int 1

# Set the Finder prefs for showing a few different volumes on the Desktop.
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Run the screensaver if we're in the bottom-left hot corner.
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

# Hide Safari's bookmark bar.
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Show overlay status URL
defaults write com.apple.Safari ShowOverlayStatusBar -bool true

# Enable Develop menu / Web Inspector
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true





echo "⚙️  Applying macOS preferences..."

###############################################################################
# 🖱️ Mouse & Trackpad
###############################################################################
echo "→ Configuring mouse & trackpad speed..."
defaults write -g com.apple.mouse.scaling -float 3.0
defaults write -g com.apple.mouse.acceleration -float 1.5
defaults write -g com.apple.trackpad.scaling -float 2.5
killall cfprefsd 2>/dev/null || true

###############################################################################
# 🧱 Dock setup
###############################################################################
echo "→ Configuring Dock layout..."

# Start from a clean Dock (Finder + Trash remain)
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array

# Helper to resolve real app paths
resolve_app() {
  local bundle_id="$1"; shift
  local found
  found="$(mdfind "kMDItemCFBundleIdentifier == '$bundle_id'" | head -n1)"
  if [[ -n "$found" && -e "$found" ]]; then
    printf "%s" "$found"
    return 0
  fi
  # fallbacks
  for guess in "$@"; do
    if [[ -e "$guess" ]]; then
      printf "%s" "$guess"
      return 0
    fi
  done
  return 1
}

# Helper to add apps to Dock safely
dock_add() {
  local app_path="$1"
  if [[ ! -e "$app_path" ]]; then
    echo "⚠️  Dock skip: $app_path not found"
    return
  fi
  local url="file://$app_path"
  defaults write com.apple.dock persistent-apps -array-add "
  <dict>
    <key>tile-data</key>
    <dict>
      <key>file-data</key>
      <dict>
        <key>_CFURLString</key><string>${url}</string>
        <key>_CFURLStringType</key><integer>15</integer>
      </dict>
    </dict>
  </dict>"
}

# Resolve app paths
SAFARI_PATH="$(resolve_app com.apple.Safari /Applications/Safari.app)"
MESSAGES_PATH="$(resolve_app com.apple.iChat /System/Applications/Messages.app)"
SLACK_PATH="$(resolve_app com.tinyspeck.slackmacgap /Applications/Slack.app)"
ZOOM_PATH="$(resolve_app us.zoom.xos /Applications/zoom.us.app)"
OUTLOOK_PATH="$(resolve_app com.microsoft.Outlook '/Applications/Microsoft Outlook.app')"
CISCO_PATH="$(resolve_app com.cisco.secureclient.gui \
  '/Applications/Cisco Secure Client.app' \
  '/Applications/Cisco/Cisco Secure Client.app' \
  '/Applications/Cisco/Cisco AnyConnect Secure Mobility Client.app')"
SETTINGS_PATH="/System/Applications/System Settings.app"
LAUNCHPAD_PATH="/System/Applications/Launchpad.app"

# Add apps to Dock (Finder/Trash always there)
-e "$LAUNCHPAD_PATH" ]] && dock_add "$LAUNCHPAD_PATH" || echo "⚠️ Launchpad not found"
[[ -n "$SAFARI_PATH" ]]   && dock_add "$SAFARI_PATH"   || echo "⚠️ Safari not found"
[[ -n "$MESSAGES_PATH" ]] && dock_add "$MESSAGES_PATH" || echo "⚠️ Messages not found"
[[ -n "$SLACK_PATH" ]]    && dock_add "$SLACK_PATH"    || echo "⚠️ Slack not found"
[[ -n "$ZOOM_PATH" ]]     && dock_add "$ZOOM_PATH"     || echo "⚠️ Zoom not found"
[[ -n "$OUTLOOK_PATH" ]]  && dock_add "$OUTLOOK_PATH"  || echo "⚠️ Outlook not found"
[[ -n "$CISCO_PATH" ]]    && dock_add "$CISCO_PATH"    || echo "⚠️ Cisco not found"
[[ -e "$SETTINGS_PATH" ]] && dock_add "$SETTINGS_PATH"

# Add Downloads stack on right side
defaults write com.apple.dock persistent-others -array-add "
<dict>
  <key>tile-data</key>
  <dict>
    <key>file-data</key>
    <dict>
      <key>_CFURLString</key><string>file://${HOME}/Downloads</string>
      <key>_CFURLStringType</key><integer>15</integer>
    </dict>
    <key>displayas</key><integer>0</integer> <!-- stack -->
    <key>showas</key><integer>1</integer>   <!-- grid -->
  </dict>
  <key>tile-type</key><string>directory-tile</string>
</dict>"

# Dock appearance
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 64
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0

killall Dock

###############################################################################
# 🔄 Login items
###############################################################################
echo "→ Adding login items..."

add_login_item() {
  local name="$1"
  local app_path="$2"
  if [[ ! -e "$app_path" ]]; then
    echo "⚠️  Skipping login item (not found): $name"
    return
  fi
  osascript <<EOF
tell application "System Events"
  if exists login item "$name" then delete login item "$name"
  make login item at end with properties {name:"$name", path:"$app_path", hidden:false}
end tell
EOF
}

# Messages, Slack, Zoom, Outlook, Cisco
add_login_item "Messages" "$MESSAGES_PATH"
add_login_item "Slack" "$SLACK_PATH"
add_login_item "Zoom" "$ZOOM_PATH"
add_login_item "Microsoft Outlook" "$OUTLOOK_PATH"
add_login_item "Cisco Secure Client" "$CISCO_PATH"

echo "✅ macOS configuration applied!"
