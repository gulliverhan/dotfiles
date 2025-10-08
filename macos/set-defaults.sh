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
defaults write com.apple.Safari.plist ShowFavoritesBar -bool false

# Always show Safari's "URL display" tab in the lower left on mouseover. Strangely
# like, everyone and their LLMs on the internet thinks this is ShowStatusBar, but
# it's not.
defaults write com.apple.Safari ShowOverlayStatusBar -bool true

# Set up Safari for development.
defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true
defaults write com.apple.Safari.plist IncludeDevelopMenu -bool true
defaults write com.apple.Safari.plist WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari.plist "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true




# Set mouse tracking speed (range ~0.0 to 3.0)
defaults write -g com.apple.mouse.scaling -float 3.0


defaults write -g com.apple.mouse.acceleration -float 1.5

# Set trackpad tracking speed (range ~0 to 3)
defaults write -g com.apple.trackpad.scaling -float 2.5

echo "Customizing Dock apps + layout..."

# Start from a clean Dock (keeps Finder & Trash automatically)
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array

# Helper to add apps by path
dock_add() {
  defaults write com.apple.dock persistent-apps -array-add \
  "<dict>
      <key>tile-data</key>
      <dict>
          <key>file-data</key>
          <dict>
              <key>_CFURLString</key>
              <string>$1</string>
              <key>_CFURLStringType</key>
              <integer>0</integer>
          </dict>
      </dict>
  </dict>"
}

# Personal apps
dock_add "/System/Applications/Safari.app"
dock_add "/System/Applications/Messages.app"

# Work apps
dock_add "/Applications/Slack.app"
dock_add "/Applications/zoom.us.app"
dock_add "/Applications/Microsoft Outlook.app"
dock_add "/Applications/Cisco Secure Client.app"

# System Settings if you want it handy
dock_add "/System/Applications/System Settings.app"

# Downloads stack on the right side
defaults write com.apple.dock persistent-others -array-add \
  "<dict>
      <key>tile-data</key>
      <dict>
          <key>file-data</key>
          <dict>
              <key>_CFURLString</key>
              <string>file://${HOME}/Downloads</string>
              <key>_CFURLStringType</key>
              <integer>15</integer>
          </dict>
          <key>displayas</key>  <integer>0</integer>   <!-- 0 = stack, 1 = folder -->
          <key>showas</key>     <integer>1</integer>   <!-- 1 = grid -->
      </dict>
      <key>tile-type</key>
      <string>directory-tile</string>
  </dict>"

# Dock layout & behavior
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 64
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0

# Apply
killall Dock

# Make key apps start at login (optional)
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/System/Applications/Messages.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Slack.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/zoom.us.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Microsoft Outlook.app", hidden:false}'
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Cisco Secure Client.app", hidden:true}'
