# Modified the generated code to support completion
# Ensure that these aliases are removed from the generated code

def "nu-complete __zoxide_z" [] {
  zoxide query --list --exclude $env.PWD | lines
}

# Jump to a directory using only keywords.
def --env --wrapped z [...rest: string@"nu-complete __zoxide_z"] {
  let path = match $rest {
    [] => {'~'},
    [ '-' ] => {'-'},
    [ $arg ] if ($arg | path type) == 'dir' => {$arg}
    _ => {
      zoxide query --exclude $env.PWD -- ...$rest | str trim -r -c "\n"
    }
  }
  cd $path
}

# Jump to a directory using interactive search.
def --env --wrapped zi [...rest:string@"nu-complete __zoxide_z"] {
  cd $'(zoxide query --interactive -- ...$rest | str trim -r -c "\n")'
}
