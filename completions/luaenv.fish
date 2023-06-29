function __fish_luaenv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'luaenv' ]
    return 0
  end
  return 1
end

function __fish_luaenv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c luaenv -n '__fish_luaenv_needs_command' -a '(luaenv commands)'
for cmd in (luaenv commands)
  complete -f -c luaenv -n "__fish_luaenv_using_command $cmd" -a "(luaenv completions $cmd)"
end
