if [[ ! -o interactive ]]; then
    return
fi

compctl -K _luaenv luaenv

_luaenv() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(luaenv commands)"
  else
    completions="$(luaenv completions ${words[2,-2]})"
  fi

  reply=("${(ps:\n:)completions}")
}
