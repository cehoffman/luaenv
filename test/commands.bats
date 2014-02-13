#!/usr/bin/env bats

load test_helper

@test "commands" {
  run luaenv-commands
  assert_success
  assert_line "init"
  assert_line "rehash"
  assert_line "shell"
  refute_line "sh-shell"
  assert_line "echo"
}

@test "commands --sh" {
  run luaenv-commands --sh
  assert_success
  refute_line "init"
  assert_line "shell"
}

@test "commands in path with spaces" {
  path="${LUAENV_TEST_DIR}/my commands"
  cmd="${path}/luaenv-sh-hello"
  mkdir -p "$path"
  touch "$cmd"
  chmod +x "$cmd"

  PATH="${path}:$PATH" run luaenv-commands --sh
  assert_success
  assert_line "hello"
}

@test "commands --no-sh" {
  run luaenv-commands --no-sh
  assert_success
  assert_line "init"
  refute_line "shell"
}
