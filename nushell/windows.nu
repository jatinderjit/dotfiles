# Create a symlink for a file or directory
#
# The command fails if the destination already exists, unless the `--force` flag
# is used. In that case, the destination is replaced, but only if it is a
# symlink.
def symlink [
  source: string # The source file or directory path
  dest: string # The destination path for the symlink
  --force (-f) # Overwrite the destination if it already exists
] {
  let source = $source | path expand --strict --no-symlink
  let dest = $dest | path expand --no-symlink
  if ($dest | path exists) {
    if not $force {
      error make {msg: "destination already exists" }
    }
    if ($dest | path type) != "symlink" {
      error make {msg: "destination exists, and is not a symlink"}
    }
    rm $dest
  }

  if ($source | path type) == "dir" {
    ^cmd /c mklink /d $dest $source
  } else {
    ^cmd /c mklink $dest $source
  }
}

# List processes listening on a specific port
def ls-port [ port: int ] {
  ^pwsh /c ls-port $port
}
