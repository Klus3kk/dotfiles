#!/bin/bash

# Hyprland Setup Script for Arch Linux
# Run as regular user, will prompt for sudo when needed

set -e  # Exit on any error

echo "=========================================="
echo "    Hyprland Setup Script for Arch Linux"
echo "=========================================="
echo

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "Don't run this script as root! Run as your regular user."
   exit 1
fi

# Update system first
echo "Updating system packages..."
sudo pacman -Syu --noconfirm

echo "Installing Hyprland and core components..."
sudo pacman -S --noconfirm \
    hyprland \
    hyprpaper \
    xdg-desktop-portal-hyprland \
    qt5-wayland \
    qt6-wayland \
    polkit-gnome

echo "Installing your chosen applications..."
sudo pacman -S --noconfirm \
    rofi-wayland \
    eww \
    dolphin \
    swaync \
    grim \
    slurp \
    swaylock

echo "Installing audio system..."
sudo pacman -S --noconfirm \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    wireplumber \
    pavucontrol

echo "Installing essential utilities..."
sudo pacman -S --noconfirm \
    wl-clipboard \
    cliphist \
    ttf-dejavu \
    noto-fonts \
    noto-fonts-emoji \
    networkmanager \
    nm-applet \
    bluez \
    bluez-utils \
    blueman

echo "Creating configuration directories..."
mkdir -p ~/.config/{hypr,rofi,eww,swaync}

echo "Setting up Hyprland configuration..."
cat > ~/.config/hypr/hyprland.conf << 'EOF'
# Hyprland Configuration

# Monitor configuration (adjust as needed)
monitor=,preferred,auto,auto

# Startup applications
exec-once = waybar
exec-once = hyprpaper
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = swaync
exec-once = nm-applet
exec-once = blueman-applet
exec-once = wl-paste --watch cliphist store

# Environment variables
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct

# Input configuration
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = true
    }
    sensitivity = 0
}

# General settings
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
    allow_tearing = false
}

# Decoration (transparency effects)
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 8
        passes = 3
        new_optimizations = true
    }
    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# Animations
animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Layout
dwindle {
    pseudotile = true
    preserve_split = true
}

# Window rules for transparency
windowrulev2 = opacity 0.9 0.9,class:^(dolphin)$
windowrulev2 = opacity 0.9 0.9,class:^(rofi)$

# Keybindings
$mainMod = SUPER

# Basic bindings
bind = $mainMod, Q, exec, kitty
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, dolphin
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, rofi -show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,

# Screenshots
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
bind = $mainMod, Print, exec, grim - | wl-copy

# Volume controls
bind = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bind = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bind = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# Brightness controls (if laptop)
bind = , XF86MonBrightnessUp, exec, brightnessctl set 10%+
bind = , XF86MonBrightnessDown, exec, brightnessctl set 10%-

# Move focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move windows to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Mouse bindings
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Lock screen
bind = $mainMod, L, exec, swaylock
EOF

echo "Setting up basic Waybar configuration..."
mkdir -p ~/.config/waybar
cat > ~/.config/waybar/config << 'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["hyprland/window"],
    "modules-right": ["pulseaudio", "network", "cpu", "memory", "battery", "clock"],
    
    "hyprland/workspaces": {
        "disable-scroll": true,
        "all-outputs": true,
        "format": "{icon}",
        "format-icons": {
            "1": "",
            "2": "",
            "3": "",
            "4": "",
            "5": "",
            "urgent": "",
            "focused": "",
            "default": ""
        }
    },
    
    "clock": {
        "format": "{:%H:%M}",
        "format-alt": "{:%A, %B %d, %Y (%R)}",
        "tooltip-format": "<tt><small>{calendar}</small></tt>",
        "calendar": {
            "mode"          : "year",
            "mode-mon-col"  : 3,
            "weeks-pos"     : "right",
            "on-scroll"     : 1,
            "on-click-right": "mode",
            "format": {
                "months":     "<span color='#ffead3'><b>{}</b></span>",
                "days":       "<span color='#ecc6d9'><b>{}</b></span>",
                "weeks":      "<span color='#99ffdd'><b>W{}</b></span>",
                "weekdays":   "<span color='#ffcc66'><b>{}</b></span>",
                "today":      "<span color='#ff6699'><b><u>{}</u></b></span>"
            }
        }
    },
    
    "cpu": {
        "format": "{usage}% ",
        "tooltip": false
    },
    
    "memory": {
        "format": "{}% "
    },
    
    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{capacity}% {icon}",
        "format-charging": "{capacity}% ",
        "format-plugged": "{capacity}% ",
        "format-alt": "{time} {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "format-linked": "{ifname} (No IP) ",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}"
    },
    
    "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-bluetooth": "{volume}% {icon}",
        "format-bluetooth-muted": " {icon}",
        "format-muted": "",
        "format-source": "{volume}% ",
        "format-source-muted": "",
        "format-icons": {
            "headphone": "",
            "hands-free": "",
            "headset": "",
            "phone": "",
            "portable": "",
            "car": "",
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    }
}
EOF

cat > ~/.config/waybar/style.css << 'EOF'
* {
    font-family: "Noto Sans";
    font-size: 14px;
}

window#waybar {
    background-color: rgba(43, 48, 59, 0.9);
    border-bottom: 3px solid rgba(100, 114, 125, 0.5);
    color: #ffffff;
    transition-property: background-color;
    transition-duration: .5s;
}

#workspaces button {
    padding: 0 5px;
    background-color: transparent;
    color: #ffffff;
    border: none;
    border-radius: 0;
}

#workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
}

#workspaces button.focused {
    background-color: #64727D;
}

#workspaces button.urgent {
    background-color: #eb4d4b;
}

#clock,
#battery,
#cpu,
#memory,
#network,
#pulseaudio {
    padding: 0 10px;
    color: #ffffff;
}

#battery.charging, #battery.plugged {
    color: #ffffff;
    background-color: #26A65B;
}

#battery.critical:not(.charging) {
    background-color: #f53c3c;
    color: #ffffff;
    animation-name: blink;
    animation-duration: 0.5s;
    animation-timing-function: linear;
    animation-iteration-count: infinite;
    animation-direction: alternate;
}

@keyframes blink {
    to {
        background-color: #ffffff;
        color: #000000;
    }
}
EOF

echo "Setting up hyprpaper configuration..."
cat > ~/.config/hypr/hyprpaper.conf << 'EOF'
preload = ~/Pictures/wallpaper.jpg
wallpaper = ,~/Pictures/wallpaper.jpg
splash = false
EOF

echo "Setting up swaylock configuration..."
mkdir -p ~/.config/swaylock
cat > ~/.config/swaylock/config << 'EOF'
daemonize
show-failed-attempts
clock
screenshot
effect-blur=9x5
effect-vignette=0.5:0.5
color=1f1d2e80
font="Sans"
indicator
indicator-radius=200
indicator-thickness=20
line-color=1f1d2e
ring-color=191724
inside-color=1f1d2e
key-hl-color=eb6f92
separator-color=00000000
text-color=e0def4
text-caps-lock-color=""
line-ver-color=eb6f92
ring-ver-color=eb6f92
inside-ver-color=1f1d2e
text-ver-color=e0def4
ring-wrong-color=31748f
text-wrong-color=31748f
inside-wrong-color=1f1d2e
inside-clear-color=1f1d2e
text-clear-color=e0def4
ring-clear-color=9ccfd8
line-clear-color=1f1d2e
line-wrong-color=1f1d2e
bs-hl-color=31748f
grace=2
grace-no-mouse
grace-no-touch
datestr="%a, %B %e"
timestr="%I:%M %p"
fade-in="0.1"
ignore-empty-password
EOF

echo "Creating wallpaper directory..."
mkdir -p ~/Pictures
echo "Note: Place your wallpaper at ~/Pictures/wallpaper.jpg"

echo "Enabling services..."
sudo systemctl enable NetworkManager
sudo systemctl enable bluetooth

# Start audio services
systemctl --user enable pipewire pipewire-pulse wireplumber

echo
echo "=========================================="
echo "Installation complete!"
echo "=========================================="
echo
echo "Next steps:"
echo "1. Reboot your system"
echo "2. At login, select Hyprland as your session"
echo "3. Add a wallpaper to ~/Pictures/wallpaper.jpg"
echo
echo "Key bindings:"
echo "  Super + Q     = Open terminal"
echo "  Super + R     = Open rofi launcher"
echo "  Super + E     = Open file manager"
echo "  Super + C     = Close window"
echo "  Super + L     = Lock screen"
echo "  Print         = Screenshot selection"
echo "  Super + Print = Screenshot full screen"
echo
echo "The script has set up transparency effects and all your requested components."
echo "Enjoy your new Hyprland setup!"
