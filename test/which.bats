#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${LUAENV_ROOT}/versions/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "1.8" "lua"
  create_executable "2.0" "rspec"

  LUAENV_VERSION=1.8 run luaenv-which lua
  assert_success "${LUAENV_ROOT}/versions/1.8/bin/lua"

  LUAENV_VERSION=2.0 run luaenv-which rspec
  assert_success "${LUAENV_ROOT}/versions/2.0/bin/rspec"
}

@test "searches PATH for system version" {
  create_executable "${LUAENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${LUAENV_ROOT}/shims" "kill-all-humans"

  LUAENV_VERSION=system run luaenv-which kill-all-humans
  assert_success "${LUAENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims prepended)" {
  create_executable "${LUAENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${LUAENV_ROOT}/shims" "kill-all-humans"

  PATH="${LUAENV_ROOT}/shims:$PATH" LUAENV_VERSION=system run luaenv-which kill-all-humans
  assert_success "${LUAENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims appended)" {
  create_executable "${LUAENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${LUAENV_ROOT}/shims" "kill-all-humans"

  PATH="$PATH:${LUAENV_ROOT}/shims" LUAENV_VERSION=system run luaenv-which kill-all-humans
  assert_success "${LUAENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims spread)" {
  create_executable "${LUAENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${LUAENV_ROOT}/shims" "kill-all-humans"

  PATH="${LUAENV_ROOT}/shims:${LUAENV_ROOT}/shims:/tmp/non-existent:$PATH:${LUAENV_ROOT}/shims" \
    LUAENV_VERSION=system run luaenv-which kill-all-humans
  assert_success "${LUAENV_TEST_DIR}/bin/kill-all-humans"
}

@test "version not installed" {
  create_executable "2.0" "rspec"
  LUAENV_VERSION=1.9 run luaenv-which rspec
  assert_failure "luaenv: version \`1.9' is not installed"
}

@test "no executable found" {
  create_executable "1.8" "rspec"
  LUAENV_VERSION=1.8 run luaenv-which rake
  assert_failure "luaenv: rake: command not found"
}

@test "executable found in other versions" {
  create_executable "1.8" "lua"
  create_executable "1.9" "rspec"
  create_executable "2.0" "rspec"

  LUAENV_VERSION=1.8 run luaenv-which rspec
  assert_failure
  assert_output <<OUT
luaenv: rspec: command not found

The \`rspec' command exists in these Lua versions:
  1.9
  2.0
OUT
}

@test "carries original IFS within hooks" {
  hook_path="${LUAENV_TEST_DIR}/luaenv.d"
  mkdir -p "${hook_path}/which"
  cat > "${hook_path}/which/hello.bash" <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  LUAENV_HOOK_PATH="$hook_path" IFS=$' \t\n' LUAENV_VERSION=system run luaenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "discovers version from luaenv-version-name" {
  mkdir -p "$LUAENV_ROOT"
  cat > "${LUAENV_ROOT}/version" <<<"1.8"
  create_executable "1.8" "lua"

  mkdir -p "$LUAENV_TEST_DIR"
  cd "$LUAENV_TEST_DIR"

  LUAENV_VERSION= run luaenv-which lua
  assert_success "${LUAENV_ROOT}/versions/1.8/bin/lua"
}
