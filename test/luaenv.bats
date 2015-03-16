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

@test "adds its own libexec to PATH" {
  run luaenv echo "PATH"
  assert_success "${BATS_TEST_DIRNAME%/*}/libexec:$PATH"
}

@test "adds plugin bin dirs to PATH" {
  mkdir -p "$LUAENV_ROOT"/plugins/lua-build/bin
  mkdir -p "$LUAENV_ROOT"/plugins/luaenv-each/bin
  run luaenv echo -F: "PATH"
  assert_success
  assert_line 0 "${BATS_TEST_DIRNAME%/*}/libexec"
  assert_line 1 "${LUAENV_ROOT}/plugins/lua-build/bin"
  assert_line 2 "${LUAENV_ROOT}/plugins/luaenv-each/bin"
}

@test "LUAENV_HOOK_PATH preserves value from environment" {
  LUAENV_HOOK_PATH=/my/hook/path:/other/hooks run luaenv echo -F: "LUAENV_HOOK_PATH"
  assert_success
  assert_line 0 "/my/hook/path"
  assert_line 1 "/other/hooks"
  assert_line 2 "${LUAENV_ROOT}/luaenv.d"
}

@test "LUAENV_HOOK_PATH includes luaenv built-in plugins" {
  run luaenv echo "LUAENV_HOOK_PATH"
  assert_success ":${LUAENV_ROOT}/luaenv.d:${BATS_TEST_DIRNAME%/*}/luaenv.d:/usr/local/etc/luaenv.d:/etc/luaenv.d:/usr/lib/luaenv/hooks"
}
