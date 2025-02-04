{
  lib,
  username,
  host,
  config,
  ...
}:

let
  inherit (import ../hosts/${host}/variables.nix)
    browser
    terminal
    extraMonitorSettings
    keyboardLayout
    ;
in
with lib;
{
  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    extraConfig = ''
    exec-once = /nix/store/af9ngaf6xzm44506ycw8fdnxkwib2s7p-dbus-1.14.10/bin/dbus-update-activation-environment --systemd DISPLAY HYPRLAND_INSTANCE_SIGNATURE WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target
    decoration {
      shadow {
        color=rgba(e2e2e299)
      }
    }

    general {
      col.active_border=rgb(5d5f5c)
      col.inactive_border=rgb(525254)
    }

    group {
      groupbar {
        col.active=rgb(5d5f5c)
        col.inactive=rgb(525254)
        text_color=rgb(1b1b1b)
      }
      col.border_active=rgb(5d5f5c)
      col.border_inactive=rgb(525254)
      col.border_locked_active=rgb(5d5f5e)
    }

    misc {
      background_color=rgb(e2e2e2)
    }
    exec-once=/nix/store/fbg3vdpvq1n1al56qmjhcwr0w4l0rzjf-hyprpanel/bin/hyprpanel
    ### MONITORS ###
    monitor = DP-4, 1920x1080@165, 0x0, 1
    monitor = DP-5, 1920x1080@165, 1920x0, 1
    monitor = DP-3, 1920x1080@165, 3840x0, 1

    ### PROGRAMS ###
    $terminal = kitty
    $appLauncher = rofi -show drun
    $wallpaperManager = hyprpaper

    ### AUTOSTART ####
    exec-once = hyprpaper
    exec-once = hyprpanel
    exec-once = systemctl --user start hyprpolkitagent

    ### ENVIRONMENT VARIABLES ###
    env = XCURSOR_SIZE,24
    env = HYPRCURSOR_SIZE,24


    ### LOOK AND FEEL ###
    general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = $color9
    col.inactive_border = $color5
    resize_on_border = false
    allow_tearing = false
    layout = dwindle
    }

    decoration {
            rounding = 10
            active_opacity = 0.8
            inactive_opacity = 0.7
            fullscreen_opacity = 1
            blur {
                    enabled = true
                    size = 3
                    passes = 5
                    new_optimizations = true
                    ignore_opacity = true
                    xray = false
                    popups = true
            }
            shadow {
                enabled = true
                range = 5
                render_power = 2
                color = $color0
            }
    }

    #-----------visual elements------------#
    #--------------------------------------#
    animations {
        enabled = yes

        bezier = shot, 0.2, 1.0, 0.2, 1.0
        bezier = swipe, 0.6, 0.0, 0.2, 1.05
        bezier = linear, 0.0, 0.0, 1.0, 1.0
        bezier = progressive, 1.0, 0.0, 0.6, 1.0

        
        animation = windows, 1, 6, shot, slide
        animation = workspaces, 1, 6, swipe, slide
        animation = fade, 1, 4, progressive
    }

    #-----------layout specific elements-------------# 
    #------------------------------------------------#
    dwindle {
        pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true # You probably want this
    }

    master {
        new_status = master
    }

    #---------------miscellaneous-----------------#
    #---------------------------------------------#
    misc {
        force_default_wallpaper = 1 # Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true # If true disables the random hyprland logo / anime girl background. :(
    }
    # Ref https://wiki.hyprland.org/Configuring/Workspace-Rules/
    # "Smart gaps" / "No gaps when only"
    # uncomment all if you wish to use that.
    # workspace = w[tv1], gapsout:0, gapsin:0
    # workspace = f[1], gapsout:0, gapsin:0
    # windowrulev2 = bordersize 0, floating:0, onworkspace:w[tv1]
    # windowrulev2 = rounding 0, floating:0, onworkspace:w[tv1]
    # windowrulev2 = bordersize 0, floating:0, onworkspace:f[1]
    # windowrulev2 = rounding 0, floating:0, onworkspace:f[1]

    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    dwindle {
        pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true # You probably want this
    }

    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    master {
        new_status = master
    }

    # https://wiki.hyprland.org/Configuring/Variables/#misc
    misc {
        force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
    }


    ### INPUT ###
    # https://wiki.hyprland.org/Configuring/Variables/#input

    input {
        kb_layout = fr
        follow_mouse = 1
        sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
        touchpad {
            natural_scroll = false
        }
    }

    gestures {
        workspace_swipe = false
    }

    device {
        name = epic-mouse-v1
        sensitivity = -0.5
    }

    ### KEYBINDINGS ###
    # See https://wiki.hyprland.org/Configuring/Keywords/

    $mainMod = SUPER

    # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
    bind = $mainMod, T, exec, $terminal
    bind = $mainMod, Q, killactive,
    bind = $mainMod, M, exit,
    bind = $mainMod, E, exec, $fileManager
    bind = $mainMod, F, togglefloating,
    bind = $mainMod, SPACE, exec, $appLauncher
    bind = $mainMod, P, pseudo, # dwindle
    bind = $mainMod, J, togglesplit, # dwindle

    # Move focus with mainMod + arrow keys
    bind = $mainMod, left, movefocus, l
    bind = $mainMod, right, movefocus, r
    bind = $mainMod, up, movefocus, u
    bind = $mainMod, down, movefocus, d

    # Switch workspaces with mainMod + [0-9]
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

    # Move active window to a workspace with mainMod + SHIFT + [0-9]
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

    # Example special workspace (scratchpad)
    bind = $mainMod, S, togglespecialworkspace, magic
    bind = $mainMod SHIFT, S, movetoworkspace, special:magic

    # Scroll through existing workspaces with mainMod + scroll
    bind = $mainMod, mouse_down, workspace, e+1
    bind = $mainMod, mouse_up, workspace, e-1

    # Move/resize windows with mainMod + LMB/RMB and dragging
    bindm = $mainMod, mouse:272, movewindow
    bindm = $mainMod, mouse:273, resizewindow

    # Laptop multimedia keys for volume and LCD brightness
    bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
    bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    bindel = ,XF86MonBrightnessUp, exec, brightnessctl s 10%+
    bindel = ,XF86MonBrightnessDown, exec, brightnessctl s 10%-

    # Requires playerctl
    bindl = , XF86AudioNext, exec, playerctl next
    bindl = , XF86AudioPause, exec, playerctl play-pause
    bindl = , XF86AudioPlay, exec, playerctl play-pause
    bindl = , XF86AudioPrev, exec, playerctl previous


    ### WINDOWS AND WORKSPACES ###

    # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
    # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

    # Example windowrule v1
    # windowrule = float, ^(kitty)$

    # Example windowrule v2
    # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

    # Ignore maximize requests from apps. You'll probably like this.
    windowrulev2 = suppressevent maximize, class:.*

    # Fix some dragging issues with XWayland
    windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0

    '';
  };
}
