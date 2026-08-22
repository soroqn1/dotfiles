#!/usr/bin/env bash

# Resolve current focused workspace (provided directly by AeroSpace trigger or fast query)
FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null || echo "1")}"

# Lookup map for application icons (using sketchybar-app-font ligatures)
declare -A ICON_MAP=(
  # Terminals & Editors
  ["Ghostty"]=":ghostty:"
  ["Alacritty"]=":alacritty:"
  ["kitty"]=":kitty:"
  ["WezTerm"]=":wezterm:"
  ["iTerm"]=":iterm:"
  ["iTerm2"]=":iterm:"
  ["Terminal"]=":terminal:"
  ["Neovide"]=":neovide:"
  ["neovide"]=":neovide:"
  ["MacVim"]=":vim:"
  ["VimR"]=":vim:"
  ["Emacs"]=":emacs:"
  ["Code"]=":code:"
  ["Code - Insiders"]=":code:"
  ["Visual Studio Code"]=":code:"
  ["Cursor"]=":cursor:"
  ["Zed"]=":zed:"
  ["Sublime Text"]=":sublime_text:"
  ["Xcode"]=":xcode:"
  ["IntelliJ IDEA"]=":idea:"
  ["PyCharm"]=":pycharm:"
  ["WebStorm"]=":web_storm:"
  ["GoLand"]=":goland:"
  ["DataGrip"]=":datagrip:"
  ["Rider"]=":rider:"
  ["Android Studio"]=":android_studio:"
  ["Godot"]=":godot:"

  # Browsers
  ["Dia"]=":dia:"
  ["dia"]=":dia:"
  ["company.thebrowser.dia"]=":dia:"
  ["Safari"]=":safari:"
  ["Safari Technology Preview"]=":safari:"
  ["Google Chrome"]=":google_chrome:"
  ["Google Chrome Canary"]=":google_chrome:"
  ["Chromium"]=":google_chrome:"
  ["Arc"]=":arc:"
  ["Brave Browser"]=":brave_browser:"
  ["Zen Browser"]=":zen_browser:"
  ["Zen"]=":zen_browser:"
  ["Firefox"]=":firefox:"
  ["Firefox Developer Edition"]=":firefox_developer_edition:"
  ["Firefox Nightly"]=":firefox_developer_edition:"
  ["LibreWolf"]=":libre_wolf:"
  ["Vivaldi"]=":vivaldi:"
  ["Microsoft Edge"]=":microsoft_edge:"
  ["Opera"]=":opera:"
  ["Tor Browser"]=":tor_browser:"
  ["Orion"]=":orion:"
  ["Yandex Browser"]=":yandex_browser:"
  ["Yandex"]=":yandex_browser:"
  ["Yandex Browser"]=":yandex_browser:"

  # Communication & Social
  ["Telegram"]=":telegram:"
  ["Discord"]=":discord:"
  ["Discord Canary"]=":discord:"
  ["Slack"]=":slack:"
  ["Messages"]=":messages:"
  ["Signal"]=":signal:"
  ["WhatsApp"]=":whats_app:"
  ["‎WhatsApp"]=":whats_app:"
  ["Element"]=":element:"
  ["Mattermost"]=":mattermost:"
  ["Zulip"]=":zulip:"
  ["Session"]=":session:"
  ["zoom.us"]=":zoom:"
  ["Zoom"]=":zoom:"
  ["Microsoft Teams"]=":microsoft_teams:"
  ["Microsoft Teams (work or school)"]=":microsoft_teams:"
  ["Skype"]=":skype:"
  ["WeChat"]=":wechat:"
  ["FaceTime"]=":face_time:"
  ["Mail"]=":mail:"
  ["Canary Mail"]=":mail:"
  ["Superhuman"]=":mail:"
  ["Thunderbird"]=":thunderbird:"
  ["Spark"]=":spark:"
  ["Proton Mail"]=":proton_mail:"
  ["Microsoft Outlook"]=":microsoft_outlook:"

  # Productivity & Notes
  ["Obsidian"]=":obsidian:"
  ["Notion"]=":notion:"
  ["Notion Calendar"]=":calendar:"
  ["Notes"]=":notes:"
  ["Reminders"]=":reminders:"
  ["Calendar"]=":calendar:"
  ["Fantastical"]=":calendar:"
  ["Cron"]=":calendar:"
  ["Things"]=":things:"
  ["Todoist"]=":todoist:"
  ["TickTick"]=":tick_tick:"
  ["Linear"]=":linear:"
  ["Trello"]=":trello:"
  ["ClickUp"]=":click_up:"
  ["Miro"]=":miro:"
  ["Freeform"]=":freeform:"
  ["Logseq"]=":logseq:"
  ["Bear"]=":bear:"
  ["Anytype"]=":anytype:"
  ["Typora"]=":text:"
  ["ChatGPT"]=":openai:"
  ["Claude"]=":claude:"
  ["LM Studio"]=":lm_studio:"

  # Design & Media
  ["Figma"]=":figma:"
  ["Sketch"]=":sketch:"
  ["Adobe Photoshop"]=":photoshop:"
  ["Photoshop"]=":photoshop:"
  ["Adobe Illustrator"]=":illustrator:"
  ["Illustrator"]=":illustrator:"
  ["Adobe Lightroom"]=":lightroom:"
  ["Affinity Designer"]=":affinity_designer:"
  ["Affinity Photo"]=":affinity_photo:"
  ["Blender"]=":blender:"
  ["DaVinci Resolve"]=":davinciresolve:"
  ["Final Cut Pro"]=":final_cut_pro:"
  ["Music"]=":music:"
  ["Spotify"]=":spotify:"
  ["Apple Music"]=":music:"
  ["Yandex Music"]=":yandex_music:"
  ["TIDAL"]=":tidal:"
  ["Deezer"]=":deezer:"
  ["VLC"]=":vlc:"
  ["IINA"]=":iina:"
  ["mpv"]=":mpv:"
  ["QuickTime Player"]=":quicktime:"
  ["Podcasts"]=":podcasts:"
  ["OBS"]=":obsstudio:"

  # Utilities & Tools
  ["Finder"]=":finder:"
  ["System Settings"]=":gear:"
  ["System Preferences"]=":gear:"
  ["Activity Monitor"]=":activity_monitor:"
  ["1Password"]=":one_password:"
  ["Bitwarden"]=":bit_warden:"
  ["KeePassXC"]=":kee_pass_x_c:"
  ["Docker"]=":docker:"
  ["Docker Desktop"]=":docker:"
  ["OrbStack"]=":orbstack:"
  ["Postman"]=":postman:"
  ["Insomnia"]=":insomnia:"
  ["TablePlus"]=":tableplus:"
  ["DBeaver"]=":dbeaver:"
  ["Sequel Ace"]=":sequel_ace:"
  ["Fork"]=":fork:"
  ["GitHub Desktop"]=":git_hub:"
  ["Tower"]=":tower:"
  ["Raycast"]=":raycast:"
  ["Calculator"]=":calculator:"
  ["Preview"]=":preview:"
  ["PDF Expert"]=":pdf_expert:"
  ["CleanMyMac X"]=":desktop:"
  ["Pearcleaner"]=":pearcleaner:"
  ["UTM"]=":utm:"
  ["Parallels Desktop"]=":parallels:"
  ["qBittorrent"]=":qbittorrent:"
)

# Resolve focused app for the active workspace
FOCUSED_APP="$(aerospace list-windows --focused --format "%{app-name}" 2>/dev/null)"

# Map exactly one frontmost/relevant app icon per workspace
declare -A SPACE_APPS

# If we have a focused window on the focused workspace, prioritize it
if [[ -n "$FOCUSED_APP" && -n "$FOCUSED" ]]; then
  SPACE_APPS["$FOCUSED"]="$FOCUSED_APP"
fi

# Fill in the primary app for other workspaces
while IFS="|" read -r sid app; do
  [[ -z "$sid" || -z "$app" ]] && continue
  if [[ -z "${SPACE_APPS[$sid]}" ]]; then
    SPACE_APPS["$sid"]="$app"
  fi
done < <(aerospace list-windows --all --format "%{workspace}|%{app-name}" 2>/dev/null)

ARGS=()

for sid in {1..9}; do
  app="${SPACE_APPS[$sid]}"
  is_focused=$([ "$sid" = "$FOCUSED" ] && echo 1 || echo 0)

  if [ -n "$app" ]; then
    icon="${ICON_MAP[$app]:-}"
    if [[ -z "$icon" ]]; then
      app_lower="${app,,}"
      icon="${ICON_MAP[$app_lower]:-}"
    fi
    if [[ -z "$icon" ]]; then
      if [[ "$app_lower" == *"dia"* ]]; then icon=":dia:"
      elif [[ "$app_lower" == *"chrome"* ]]; then icon=":google_chrome:"
      elif [[ "$app_lower" == *"ghostty"* ]]; then icon=":ghostty:"
      elif [[ "$app_lower" == *"telegram"* ]]; then icon=":telegram:"
      elif [[ "$app_lower" == *"obsidian"* ]]; then icon=":obsidian:"
      elif [[ "$app_lower" == *"safari"* ]]; then icon=":safari:"
      elif [[ "$app_lower" == *"firefox"* ]]; then icon=":firefox:"
      elif [[ "$app_lower" == *"code"* || "$app_lower" == *"cursor"* ]]; then icon=":code:"
      else icon=":default:"
      fi
    fi
  else
    icon=""
  fi

  if [ "$is_focused" -eq 1 ]; then
    # Active workspace: bright frosted glass pill
    if [ -n "$icon" ]; then
      ARGS+=(
        --set "space.$sid"
        icon.color=0xffffffff
        icon.font="JetBrainsMono Nerd Font:Bold:12.0"
        icon.padding_left=7
        icon.padding_right=3
        icon.y_offset=0
        label="$icon"
        label.color=0xffffffff
        label.font="sketchybar-app-font:Regular:13.0"
        label.padding_left=3
        label.padding_right=7
        label.y_offset=0
        label.drawing=on
        background.color=0x38ffffff
        background.border_color=0x55ffffff
        background.border_width=1
        background.height=23
        background.corner_radius=6
        background.drawing=on
      )
    else
      ARGS+=(
        --set "space.$sid"
        icon.color=0xffffffff
        icon.font="JetBrainsMono Nerd Font:Bold:12.0"
        icon.padding_left=7
        icon.padding_right=7
        icon.y_offset=0
        label.drawing=off
        background.color=0x38ffffff
        background.border_color=0x55ffffff
        background.border_width=1
        background.height=23
        background.corner_radius=6
        background.drawing=on
      )
    fi
  elif [ -n "$icon" ]; then
    # Occupied workspace (inactive with windows): subtle translucent glass pill
    ARGS+=(
      --set "space.$sid"
      icon.color=0xd0ffffff
      icon.font="JetBrainsMono Nerd Font:Bold:12.0"
      icon.padding_left=7
      icon.padding_right=3
      icon.y_offset=0
      label="$icon"
      label.color=0xd0ffffff
      label.font="sketchybar-app-font:Regular:13.0"
      label.padding_left=3
      label.padding_right=7
      label.y_offset=0
      label.drawing=on
      background.color=0x14ffffff
      background.border_color=0x20ffffff
      background.border_width=1
      background.height=23
      background.corner_radius=6
      background.drawing=on
    )
  else
    # Empty workspace: muted number only, identical font & baseline
    ARGS+=(
      --set "space.$sid"
      icon.color=0x38ffffff
      icon.font="JetBrainsMono Nerd Font:Bold:12.0"
      icon.padding_left=6
      icon.padding_right=6
      icon.y_offset=0
      label.drawing=off
      background.drawing=off
    )
  fi
done

# Apply all changes in a single atomic batch
sketchybar "${ARGS[@]}"
