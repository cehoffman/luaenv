#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${LUAENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$LUAENV_TEST_DIR"
  cd "$LUAENV_TEST_DIR"
}

stub_system_lua() {
  local stub="${LUAENV_TEST_DIR}/bin/lua"
  mkdir -p "$(dirname "$stub")"
  touch "$stub" && chmod +x "$stub"
}

@test "no versions installed" {
  stub_system_lua
  assert [ ! -d "${LUAENV_ROOT}/versions" ]
  run luaenv-versions
  assert_success "* system (set by ${LUAENV_ROOT}/version)"
}

@test "bare output no versions installed" {
  assert [ ! -d "${LUAENV_ROOT}/versions" ]
  run luaenv-versions --bare
  assert_success ""
}

@test "single version installed" {
  stub_system_lua
  create_version "1.9"
  run luaenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${LUAENV_ROOT}/version)
  1.9
OUT
}

@test "single version bare" {
  create_version "1.9"
  run luaenv-versions --bare
  assert_success "1.9"
}

@test "multiple versions" {
  stub_system_lua
  create_version "1.8.7"
  create_version "1.9.3"
  create_version "2.0.0"
  run luaenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${LUAENV_ROOT}/version)
  1.8.7
  1.9.3
  2.0.0
OUT
}

@test "indicates current version" {
  stub_system_lua
  create_version "1.9.3"
  create_version "2.0.0"
  LUAENV_VERSION=1.9.3 run luaenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by LUAENV_VERSION environment variable)
  2.0.0
OUT
}

@test "bare doesn't indicate current version" {
  create_version "1.9.3"
  create_version "2.0.0"
  LUAENV_VERSION=1.9.3 run luaenv-versions --bare
  assert_success
  assert_output <<OUT
1.9.3
2.0.0
OUT
}

@test "globally selected version" {
  stub_system_lua
  create_version "1.9.3"
  create_version "2.0.0"
  cat > "${LUAENV_ROOT}/version" <<<"1.9.3"
  run luaenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${LUAENV_ROOT}/version)
  2.0.0
OUT
}

@test "per-project version" {
  stub_system_lua
  create_version "1.9.3"
  create_version "2.0.0"
  cat > ".lua-version" <<<"1.9.3"
  run luaenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${LUAENV_TEST_DIR}/.lua-version)
  2.0.0
OUT
}
