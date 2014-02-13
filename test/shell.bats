#!/usr/bin/env bats

load test_helper

@test "no shell version" {
  mkdir -p "${LUAENV_TEST_DIR}/myproject"
  cd "${LUAENV_TEST_DIR}/myproject"
  echo "1.2.3" > .lua-version
  LUAENV_VERSION="" run luaenv-sh-shell
  assert_failure "luaenv: no shell-specific version configured"
}

@test "shell version" {
  LUAENV_SHELL=bash LUAENV_VERSION="1.2.3" run luaenv-sh-shell
  assert_success 'echo "$LUAENV_VERSION"'
}

@test "shell version (fish)" {
  LUAENV_SHELL=fish LUAENV_VERSION="1.2.3" run luaenv-sh-shell
  assert_success 'echo "$LUAENV_VERSION"'
}

@test "shell unset" {
  LUAENV_SHELL=bash run luaenv-sh-shell --unset
  assert_success "unset LUAENV_VERSION"
}

@test "shell unset (fish)" {
  LUAENV_SHELL=fish run luaenv-sh-shell --unset
  assert_success "set -e LUAENV_VERSION"
}

@test "shell change invalid version" {
  run luaenv-sh-shell 1.2.3
  assert_failure
  assert_output <<SH
luaenv: version \`1.2.3' not installed
false
SH
}

@test "shell change version" {
  mkdir -p "${LUAENV_ROOT}/versions/1.2.3"
  LUAENV_SHELL=bash run luaenv-sh-shell 1.2.3
  assert_success 'export LUAENV_VERSION="1.2.3"'
}

@test "shell change version (fish)" {
  mkdir -p "${LUAENV_ROOT}/versions/1.2.3"
  LUAENV_SHELL=fish run luaenv-sh-shell 1.2.3
  assert_success 'setenv LUAENV_VERSION "1.2.3"'
}
