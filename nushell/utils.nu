export def is-installed [bin: string]: nothing -> bool {
  which $bin | is-not-empty
}


export def --env add-path [path: string] {
  $env.PATH = ($env.PATH | insert 0 $path)
}
