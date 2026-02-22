# Ne rien faire si le shell n'est pas interactif
[[ $- != *i* ]] && return

# ── Couleurs (dircolors) ─────────────────────────────────────
eval "$(dircolors -b ~/.dircolors)"

# ── Outils & intégrations ────────────────────────────────────
eval "$(zoxide init bash)"
eval "$(starship init bash)"

# ── Aliases : NixOS ──────────────────────────────────────────
alias nixswitch="sudo nixos-rebuild switch --flake $HOME/dev/dotfiles#nixos --show-trace"
alias logs-home-manager="journalctl -xe --unit home-manager-mhd"

# ── Aliases : Dotfiles ───────────────────────────────────────
alias install-dots="sh $HOME/dev/dotfiles/install.sh"

# ── Aliases : Utilitaires ────────────────────────────────────
alias clearTofi="rm -rf $HOME/.cache/tofi-drun"

alias claude="claude --dangerously-skip-permissions"

cdf () {
  local git_dir="$HOME/dev/"
  local dir

  dir=$(ls -1 "$git_dir" | fzf --prompt="cd > ") || return
  cd "$git_dir/$dir" || return
}

# ── Variables d'environnement ─────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"

# ── PATH ──────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"

export PATH="$HOME/.npm-global/bin:$PATH"


# ── Secrets (API keys, tokens, etc.) ─────────────────────────
if [ -f "$HOME/.bashrc.secrets" ]; then
    source "$HOME/.bashrc.secrets"
fi
