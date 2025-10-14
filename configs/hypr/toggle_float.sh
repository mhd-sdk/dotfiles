#!/bin/bash

# Récupère l'adresse de la fenêtre active
WINDOW=$(hyprctl activewindow -j | jq -r '.address')

# Vérifie si la fenêtre est actuellement tiled (floating: false)
IS_TILED=$(hyprctl activewindow -j | jq -r '.floating')

# Toggle le mode floating
hyprctl dispatch togglefloating

# Si la fenêtre était tiled (donc devient flottante maintenant)
if [ "$IS_TILED" = "false" ]; then
    hyprctl dispatch resizeactive exact 800 500
    hyprctl dispatch centerwindow
fi
