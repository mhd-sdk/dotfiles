# ╔══════════════════════════════════════════════════════════════╗
# ║                      .bash_profile                         ║
# ║         Chargé une seule fois à la connexion               ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Variables d'environnement ─────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"

# ── PATH ──────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"

# ── Secrets (API keys, tokens, etc.) ─────────────────────────
if [ -f "$HOME/.bashrc.secrets" ]; then
    source "$HOME/.bashrc.secrets"
fi

# ── Charger .bashrc pour les shells interactifs ───────────────
if [ -f "$HOME/.bashrc" ]; then
    source "$HOME/.bashrc"
fi
