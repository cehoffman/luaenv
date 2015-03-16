#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${LUAENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${LUAENV_ROOT}/shims" ]
  run luaenv-rehash
  assert_success ""
  assert [ -d "${LUAENV_ROOT}/shims" ]
  rmdir "${LUAENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${LUAENV_ROOT}/shims"
  chmod -w "${LUAENV_ROOT}/shims"
  run luaenv-rehash
  assert_failure "luaenv: cannot rehash: ${LUAENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${LUAENV_ROOT}/shims"
  touch "${LUAENV_ROOT}/shims/.luaenv-shim"
  run luaenv-rehash
  assert_failure "luaenv: cannot rehash: ${LUAENV_ROOT}/shims/.luaenv-shim exists"
}

@test "creates shims" {
  create_executable "1.8" "lua"
  create_executable "1.8" "rake"
  create_executable "2.0" "lua"
  create_executable "2.0" "rspec"

  assert [ ! -e "${LUAENV_ROOT}/shims/lua" ]
  assert [ ! -e "${LUAENV_ROOT}/shims/rake" ]
  assert [ ! -e "${LUAENV_ROOT}/shims/rspec" ]

  run luaenv-rehash
  assert_success ""

  run ls "${LUAENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
rake
rspec
lua
OUT
}

@test "removes outdated shims" {
  mkdir -p "${LUAENV_ROOT}/shims"
  touch "${LUAENV_ROOT}/shims/oldshim1"
  chmod +x "${LUAENV_ROOT}/shims/oldshim1"

  create_executable "2.0" "rake"
  create_executable "2.0" "lua"

  run luaenv-rehash
  assert_success ""

  assert [ ! -e "${LUAENV_ROOT}/shims/oldshim1" ]
}

@test "do exact matches when removing stale shims" {
  create_executable "2.0" "unicorn_rails"
  create_executable "2.0" "rspec-core"

  luaenv-rehash

  cp "$LUAENV_ROOT"/shims/{rspec-core,rspec}
  cp "$LUAENV_ROOT"/shims/{rspec-core,rails}
  cp "$LUAENV_ROOT"/shims/{rspec-core,uni}
  chmod +x "$LUAENV_ROOT"/shims/{rspec,rails,uni}

  run luaenv-rehash
  assert_success ""

  assert [ ! -e "${LUAENV_ROOT}/shims/rails" ]
  assert [ ! -e "${LUAENV_ROOT}/shims/rake" ]
  assert [ ! -e "${LUAENV_ROOT}/shims/uni" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 p247" "lua"
  create_executable "dirname2 preview1" "rspec"

  assert [ ! -e "${LUAENV_ROOT}/shims/lua" ]
  assert [ ! -e "${LUAENV_ROOT}/shims/rspec" ]

  run luaenv-rehash
  assert_success ""

  run ls "${LUAENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
rspec
lua
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${LUAENV_TEST_DIR}/luaenv.d"
  mkdir -p "${hook_path}/rehash"
  cat > "${hook_path}/rehash/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  LUAENV_HOOK_PATH="$hook_path" IFS=$' \t\n' run luaenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "2.0" "lua"
  LUAENV_SHELL=bash run luaenv-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${LUAENV_ROOT}/shims/lua" ]
}

@test "sh-rehash in fish" {
  create_executable "2.0" "lua"
  LUAENV_SHELL=fish run luaenv-sh-rehash
  assert_success ""
  assert [ -x "${LUAENV_ROOT}/shims/lua" ]
}
