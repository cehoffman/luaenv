#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run luaenv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${LUAENV_ROOT}/shims"
  touch "${LUAENV_ROOT}/shims/lua"
  touch "${LUAENV_ROOT}/shims/irb"
  run luaenv-shims
  assert_success
  assert_line "${LUAENV_ROOT}/shims/lua"
  assert_line "${LUAENV_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${LUAENV_ROOT}/shims"
  touch "${LUAENV_ROOT}/shims/lua"
  touch "${LUAENV_ROOT}/shims/irb"
  run luaenv-shims --short
  assert_success
  assert_line "irb"
  assert_line "lua"
}
