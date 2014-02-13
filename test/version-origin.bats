#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$LUAENV_TEST_DIR"
  cd "$LUAENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${LUAENV_ROOT}/version" ]
  run luaenv-version-origin
  assert_success "${LUAENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$LUAENV_ROOT"
  touch "${LUAENV_ROOT}/version"
  run luaenv-version-origin
  assert_success "${LUAENV_ROOT}/version"
}

@test "detects LUAENV_VERSION" {
  LUAENV_VERSION=1 run luaenv-version-origin
  assert_success "LUAENV_VERSION environment variable"
}

@test "detects local file" {
  touch .lua-version
  run luaenv-version-origin
  assert_success "${PWD}/.lua-version"
}

@test "detects alternate version file" {
  touch .luaenv-version
  run luaenv-version-origin
  assert_success "${PWD}/.luaenv-version"
}
