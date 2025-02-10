# To allow opening new tab in the same directory
# Ref: https://learn.microsoft.com/en-us/windows/terminal/tutorials/new-tab-same-directory#powershell-with-starship
function Invoke-Starship-PreCommand {
  $loc = $executionContext.SessionState.Path.CurrentLocation;
  $prompt = "$([char]27)]9;12$([char]7)"
  if ($loc.Provider.Name -eq "FileSystem")
  {
    $prompt += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
  }
  $host.ui.Write($prompt)
}

Import-Module posh-git

Invoke-Expression (&starship init powershell)

New-Alias alias New-Alias
alias which Get-Command

# Aliases
function .. { cd .. }
function ... { cd ../.. }
function .... { cd ../../.. }

Remove-Alias ls
alias ls eza
function l { ls -lah $args }

alias v nvim
alias vi nvim
alias vim nvim
function vd { nvim -d $args }

Remove-Alias cat # Get-Content
alias cat bat

function rgn { rg --no-ignore $args }  # to ignore .gitignore (and other ignore files)
function rgf { rg --files-with-matches $args }  # or `rg -l` just print filenames
function rgi { rg -i $args }
function rgfi { rgf -i $args }

function fdn { fd --no-ignore }
function fdi { fd -i }

alias j just
function glow { ~/scoop/shims/glow --pager $args }

function cdnotes { cd ~/projects/notes }
function cdjournal { cd ~/projects/journal }

function py {
  if ($args.Count -eq 0) {
    ipython
  } else {
    python $args
  }
}

# Git aliases
alias lg lazygit
function rr() { cd "$(git rev-parse --show-toplevel)" } # cd into the current git repository's root 
function ga { git add $args }
function gap { git add --patch $args }
function gb { git branch $args }
function gbD { git branch --delete --force $args }
function gbd { git branch --delete $args }
Remove-Alias gc -Force # Get-Content (cat)
function gc { git commit --verbose $args }
function gcp { git cherry-pick $args }
function gd { git diff $args }
function gdc { git diff --cached $args }
function gdcw { git diff --cached --word-diff $args }
function gf { git fetch $args }
function gfo { git fetch origin $args }
function ggl { git pull origin "$(git branch --show-current)" }
Remove-Alias gl -Force # Get-Location (pwd)
function gl { git log $args }
function glp { git log --patch $args }
Remove-Alias gm -Force # Get-Member
function gm { git merge $args }
Remove-Alias gp -Force # Get-ItemProperty
function gp { git push $args }
function gpf { git push --force-with-lease --force-if-includes $args }
function grb { git rebase $args }
function grbi { git rebase -i $args }
function grh { git reset $args }
function grs { git restore $args }
function gst { git status $args }
function gst2 { git status -uno $args } # Don't show untracked files
function gstl { git stash list }
function gstp { git stash pop $args }
function gsts { git stash show --patch $args }
function gsw { git switch $args }

#######################################

$env:YAZI_FILE_ONE = "C:\Program Files\Git\usr\bin\file.exe"

Invoke-Expression (& { (zoxide init powershell | Out-String) })
Invoke-Expression (& { (just --completions powershell | Out-String) })
