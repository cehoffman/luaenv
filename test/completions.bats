#!/usr/bin/env bats

load test_helper

create_command() {
  bin="${LUAENV_TEST_DIR}/bin"
  mkdir -p "$bin"
  echo "$2" > "${bin}/$1"
  chmod +x "${bin}/$1"
}

@test "command with no completion support" {
  create_command "luaenv-hello" "#!$BASH
    echo hello"
  run luaenv-completions hello
  assert_success ""
}

@test "command with completion support" {
  create_command "luaenv-hello" "#!$BASH
# Provide luaenv completions
if [[ \$1 = --complete ]]; then
  echo hello
else
  exit 1
fi"
  run luaenv-completions hello
  assert_success "hello"
}

@test "forwards extra arguments" {
  create_command "luaenv-hello" "#!$BASH
# provide luaenv completions
if [[ \$1 = --complete ]]; then
  shift 1
  for arg; do echo \$arg; done
else
  exit 1
fi"
  run luaenv-completions hello happy world
  assert_success
  assert_output <<OUT
happy
world
OUT
}
