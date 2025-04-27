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

alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..

alias l = ls -l

alias v = nvim
alias vi = nvim
alias vim = nvim
alias vd = nvim -d

const light_mode = {
  mode: "light",
  bat-theme: "gruvbox-light",
}

const dark_mode = {
  mode: "dark",
  bat-theme: "1337",
}

if $env.TERMINAL_COLOR_MODE? == null {
  $env.TERMINAL_COLOR_MODE = 'dark'
}

def current-mode [] {
  if $env.TERMINAL_COLOR_MODE == 'light' { $light_mode } else { $dark_mode }
}

def --env enable-dark-mode [] {
  $env.TERMINAL_COLOR_MODE = 'dark'
}

def --env enable-light-mode [] {
  $env.TERMINAL_COLOR_MODE = 'light'
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
    ipython
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
alias ggl = git pull origin 
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


# Git clone: https://github.com/nushell/nu_scripts.git
const completion_root = $nu.data-dir | path join "nu_scripts/custom-completions"

source ($completion_root | path join "bat/bat-completions.nu")
source ($completion_root | path join "cargo/cargo-completions.nu")
source ($completion_root | path join "eza/eza-completions.nu")
source ($completion_root | path join "flutter/flutter-completions.nu")
source ($completion_root | path join "git/git-completions.nu")
source ($completion_root | path join "glow/glow-completions.nu")
source ($completion_root | path join "just/just-completions.nu")
source ($completion_root | path join "make/make-completions.nu")
source ($completion_root | path join "npm/npm-completions.nu")
source ($completion_root | path join "pre-commit/pre-commit-completions.nu")
source ($completion_root | path join "rg/rg-completions.nu")
source ($completion_root | path join "rustup/rustup-completions.nu")
source ($completion_root | path join "scoop/scoop-completions.nu")
source ($completion_root | path join "ssh/ssh-completions.nu")
source ($completion_root | path join "tar/tar-completions.nu")
source ($completion_root | path join "tealdeer/tldr-completions.nu")
source ($completion_root | path join "yarn/yarn-v4-completions.nu")

source "./zoxide.nu"
