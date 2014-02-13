#!/usr/bin/env bats

load test_helper

@test "default" {
  run luaenv global
  assert_success
  assert_output "system"
}

@test "read LUAENV_ROOT/version" {
  mkdir -p "$LUAENV_ROOT"
  echo "1.2.3" > "$LUAENV_ROOT/version"
  run luaenv-global
  assert_success
  assert_output "1.2.3"
}

@test "set LUAENV_ROOT/version" {
  mkdir -p "$LUAENV_ROOT/versions/1.2.3"
  run luaenv-global "1.2.3"
  assert_success
  run luaenv global
  assert_success "1.2.3"
}

@test "fail setting invalid LUAENV_ROOT/version" {
  mkdir -p "$LUAENV_ROOT"
  run luaenv-global "1.2.3"
  assert_failure "luaenv: version \`1.2.3' not installed"
}
