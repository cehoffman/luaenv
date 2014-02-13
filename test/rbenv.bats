#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run luaenv
  assert_success
  assert [ "${lines[0]}" = "luaenv 0.4.0" ]
}

@test "invalid command" {
  run luaenv does-not-exist
  assert_failure
  assert_output "luaenv: no such command \`does-not-exist'"
}

@test "default LUAENV_ROOT" {
  LUAENV_ROOT="" HOME=/home/mislav run luaenv root
  assert_success
  assert_output "/home/mislav/.luaenv"
}

@test "inherited LUAENV_ROOT" {
  LUAENV_ROOT=/opt/luaenv run luaenv root
  assert_success
  assert_output "/opt/luaenv"
}

@test "default LUAENV_DIR" {
  run luaenv echo LUAENV_DIR
  assert_output "$(pwd)"
}

@test "inherited LUAENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  LUAENV_DIR="$dir" run luaenv echo LUAENV_DIR
  assert_output "$dir"
}

@test "invalid LUAENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  LUAENV_DIR="$dir" run luaenv echo LUAENV_DIR
  assert_failure
  assert_output "luaenv: cannot change working directory to \`$dir'"
}
