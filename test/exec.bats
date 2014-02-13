#!/usr/bin/env bats

load test_helper

create_executable() {
  name="${1?}"
  shift 1
  bin="${LUAENV_ROOT}/versions/${LUAENV_VERSION}/bin"
  mkdir -p "$bin"
  { if [ $# -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed -Ee '1s/^ +//' > "${bin}/$name"
  chmod +x "${bin}/$name"
}

@test "fails with invalid version" {
  export LUAENV_VERSION="2.0"
  run luaenv-exec lua -v
  assert_failure "luaenv: version \`2.0' is not installed"
}

@test "completes with names of executables" {
  export LUAENV_VERSION="2.0"
  create_executable "lua" "#!/bin/sh"
  create_executable "rake" "#!/bin/sh"

  luaenv-rehash
  run luaenv-completions exec
  assert_success
  assert_output <<OUT
rake
lua
OUT
}

@test "supports hook path with spaces" {
  hook_path="${LUAENV_TEST_DIR}/custom stuff/luaenv hooks"
  mkdir -p "${hook_path}/exec"
  echo "export HELLO='from hook'" > "${hook_path}/exec/hello.bash"

  export LUAENV_VERSION=system
  LUAENV_HOOK_PATH="$hook_path" run luaenv-exec env
  assert_success
  assert_line "HELLO=from hook"
}

@test "carries original IFS within hooks" {
  hook_path="${LUAENV_TEST_DIR}/luaenv.d"
  mkdir -p "${hook_path}/exec"
  cat > "${hook_path}/exec/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export LUAENV_VERSION=system
  LUAENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run luaenv-exec env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "forwards all arguments" {
  export LUAENV_VERSION="2.0"
  create_executable "lua" <<SH
#!$BASH
echo \$0
for arg; do
  # hack to avoid bash builtin echo which can't output '-e'
  printf "  %s\\n" "\$arg"
done
SH

  run luaenv-exec lua -w "/path to/lua script.rb" -- extra args
  assert_success
  assert_output <<OUT
${LUAENV_ROOT}/versions/2.0/bin/lua
  -w
  /path to/lua script.rb
  --
  extra
  args
OUT
}

@test "supports lua -S <cmd>" {
  export LUAENV_VERSION="2.0"

  # emulate `lua -S' behavior
  create_executable "lua" <<SH
#!$BASH
if [[ \$1 == "-S"* ]]; then
  found="\$(PATH="\${LUAPATH:-\$PATH}" which \$2)"
  # assert that the found executable has lua for shebang
  if head -1 "\$found" | grep lua >/dev/null; then
    \$BASH "\$found"
  else
    echo "lua: no Lua script found in input (LoadError)" >&2
    exit 1
  fi
else
  echo 'lua 2.0 (luaenv test)'
fi
SH

  create_executable "rake" <<SH
#!/usr/bin/env lua
echo hello rake
SH

  luaenv-rehash
  run lua -S rake
  assert_success "hello rake"
}
