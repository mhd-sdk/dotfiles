#!/bin/bash
hyprctl dispatch workspace 1 && hyprctl dispatch moveworkspacetomonitor 1 DP-5
hyprctl dispatch workspace 4 && hyprctl dispatch moveworkspacetomonitor 4 DP-5
hyprctl dispatch workspace 7 && hyprctl dispatch moveworkspacetomonitor 7 DP-5

hyprctl dispatch workspace 2 && hyprctl dispatch moveworkspacetomonitor 2 DP-4
hyprctl dispatch workspace 5 && hyprctl dispatch moveworkspacetomonitor 5 DP-4
hyprctl dispatch workspace 8 && hyprctl dispatch moveworkspacetomonitor 8 DP-4

hyprctl dispatch workspace 3 && hyprctl dispatch moveworkspacetomonitor 3 DP-3
hyprctl dispatch workspace 6 && hyprctl dispatch moveworkspacetomonitor 6 DP-3
hyprctl dispatch workspace 9 && hyprctl dispatch moveworkspacetomonitor 9 DP-3