# config.nu
#
# Installed by:
# version = "0.103.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

use std/dirs
use utils.nu *

$env.config.shell_integration.osc133 = false

# Use `dirs` to see the stack. And `dirs prev`, `dirs next` to navigate the stack.
alias cd = dirs add
alias pushd = dirs add
alias popd = dirs drop

# $env.config.edit_mode = 'vi'

def --env mkcd [path: string] {
  mkdir $path
  cd $path
}

alias md = mkdir

alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..

alias l = eza -l

alias v = nvim
alias vi = nvim
alias vim = nvim
alias vd = nvim -d

const light_mode = {
  mode: "light",
  bat-theme: "gruvbox-light",
  ls-colors: "catppuccin-latte",
}

const dark_mode = {
  mode: "dark",
  bat-theme: "1337",
  ls-colors: "tokyonight-moon",
}

def current-mode [] {
  if $env.TERMINAL_COLOR_MODE == 'light' { $light_mode } else { $dark_mode }
}

def --env set-color-mode [mode_config] {
  $env.TERMINAL_COLOR_MODE = ($mode_config | get mode)
  $env.LS_COLORS = ^vivid generate ($mode_config | get ls-colors)
}

def --env enable-light-mode [] {
  set-color-mode $light_mode
}

def --env enable-dark-mode [] {
  set-color-mode $dark_mode
}

if $env.TERMINAL_COLOR_MODE? == 'light' {
  enable-light-mode
} else {
  enable-dark-mode
}

alias cat = bat --theme $"(current-mode | get bat-theme)"

alias rgn = rg --no-ignore  # to ignore .gitignore (and other ignore files)
alias rgf = rg --files-with-matches # or `rg -l` just print filenames
alias rgi = rg -i
alias rgfi = rgf -i

alias fdn = fd --no-ignore
alias fdi = fd -i

alias j = just
alias glow = ~/scoop/shims/glow --pager

alias cdnotes = cd ~/projects/notes
alias cdjournal = cd ~/projects/journal

$env.EDITOR = "nvim"

const platform_config = if $nu.os-info.name == "windows" {
  "windows.nu"
} else if $nu.os-info.name == "macos" {
  "macos.nu"
} else {
  "linux.nu"
}
source ($nu.data-dir | path join $platform_config)

$env.config.completions.algorithm = "fuzzy"
source ($nu.data-dir | path join "completers.nu")


def --wrapped py [...args] {
  if ($args | is-empty) {

    # Try executing the following line on the shell.
    # It raises an error: SyntaxError: invalid character '╭' (U+256D)
    # The SyntaxError is raised only when it executes the catch block!
    # nushell bug?
    # try { ipython } catch { python }  <-- syntax error for python and python3
    # try { ipython } catch { ls }  #  <-- This works

    if (is-installed "ipython") { ipython } else { python }
  } else {
    python ...$args
  }
}

################### Start: Git Alaises
alias lg = lazygit
alias rr = cd $"(git rev-parse --show-toplevel)"  # cd into the current git repository's root 
alias ga = git add
alias gap = git add --patch
alias gb = git branch
alias gbD = git branch --delete --force
alias gbd = git branch --delete
alias gc = git commit --verbose
alias gcp = git cherry-pick
alias gd = git diff
alias gdc = git diff --cached
alias gdcw = git diff --cached --word-diff
alias gdd = git ddiff
alias gddc = git ddiff --cached
alias gf = git fetch
alias gfo = git fetch origin
def --wrapped ggl [...args] {
  if ($args | is-empty) {
    git pull origin (git rev-parse --abbrev-ref HEAD)
  } else {
    git pull origin ...$args
  }
}
alias gl = git log
alias glp = git log --patch
alias gm = git merge
alias gp = git push
alias gpf = git push --force-with-lease --force-if-includes
alias grb = git rebase
alias grbi = git rebase -i
alias grh = git reset
alias grs = git restore
alias gst = git status
alias gst2 = git status -uno # Don't show untracked files
alias gstl = git stash list
alias gstp = git stash pop
alias gsts = git stash show --patch
alias gsw = git switch

################### End: Git Alaises


def ssh-keys [] {
  ssh-add $"($env.HOMEPATH)/.ssh/id_ed25519"
  ssh-add $"($env.HOMEPATH)/.ssh/id_ed25519_oc"
}

def add-to-autoload [name: string] {
  mkdir ($nu.data-dir | path join "vendor/autoload")
  $in | save --force ($nu.data-dir | path join $"vendor/autoload/($name).nu")
}

def setup-autoloads [] {
  mise activate nu | add-to-autoload mise
  starship init nu | add-to-autoload starship
  uv generate-shell-completion nushell | add-to-autoload uv
  uvx --generate-shell-completion nushell | add-to-autoload uvx
  zoxide init nushell | add-to-autoload zoxide
  # zoxide init nushell --hook prompt | add-to-autoload zoxide-hook

  # nu_scripts custom completions is better than the default completions!
  # just --completions nushell | add-to-autoload just
}

# Custom completions
source "completions/zoxide.nu"

# Git clone: https://github.com/nushell/nu_scripts.git
source "nu_scripts/custom-completions/bat/bat-completions.nu"
source "nu_scripts/custom-completions/cargo/cargo-completions.nu"
source "nu_scripts/custom-completions/eza/eza-completions.nu"
source "nu_scripts/custom-completions/flutter/flutter-completions.nu"
source "nu_scripts/custom-completions/git/git-completions.nu"
source "nu_scripts/custom-completions/glow/glow-completions.nu"
source "nu_scripts/custom-completions/just/just-completions.nu"
source "nu_scripts/custom-completions/make/make-completions.nu"
source "nu_scripts/custom-completions/npm/npm-completions.nu"
source "nu_scripts/custom-completions/pre-commit/pre-commit-completions.nu"
source "nu_scripts/custom-completions/rg/rg-completions.nu"
source "nu_scripts/custom-completions/rustup/rustup-completions.nu"
source "nu_scripts/custom-completions/scoop/scoop-completions.nu"
source "nu_scripts/custom-completions/ssh/ssh-completions.nu"
source "nu_scripts/custom-completions/tar/tar-completions.nu"
source "nu_scripts/custom-completions/tealdeer/tldr-completions.nu"
source "nu_scripts/custom-completions/yarn/yarn-v4-completions.nu"
