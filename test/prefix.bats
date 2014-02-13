#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${LUAENV_TEST_DIR}/myproject"
  cd "${LUAENV_TEST_DIR}/myproject"
  echo "1.2.3" > .lua-version
  mkdir -p "${LUAENV_ROOT}/versions/1.2.3"
  run luaenv-prefix
  assert_success "${LUAENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  LUAENV_VERSION="1.2.3" run luaenv-prefix
  assert_failure "luaenv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${LUAENV_TEST_DIR}/bin"
  touch "${LUAENV_TEST_DIR}/bin/lua"
  chmod +x "${LUAENV_TEST_DIR}/bin/lua"
  LUAENV_VERSION="system" run luaenv-prefix
  assert_success "$LUAENV_TEST_DIR"
}

@test "prefix for invalid system" {
  PATH="$(path_without lua)" run luaenv-prefix system
  assert_failure "luaenv: system version not found in PATH"
}
