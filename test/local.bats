#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "${LUAENV_TEST_DIR}/myproject"
  cd "${LUAENV_TEST_DIR}/myproject"
}

@test "no version" {
  assert [ ! -e "${PWD}/.lua-version" ]
  run luaenv-local
  assert_failure "luaenv: no local version configured for this directory"
}

@test "local version" {
  echo "1.2.3" > .lua-version
  run luaenv-local
  assert_success "1.2.3"
}

@test "supports legacy .luaenv-version file" {
  echo "1.2.3" > .luaenv-version
  run luaenv-local
  assert_success "1.2.3"
}

@test "local .lua-version has precedence over .luaenv-version" {
  echo "1.8" > .luaenv-version
  echo "2.0" > .lua-version
  run luaenv-local
  assert_success "2.0"
}

@test "ignores version in parent directory" {
  echo "1.2.3" > .lua-version
  mkdir -p "subdir" && cd "subdir"
  run luaenv-local
  assert_failure
}

@test "ignores LUAENV_DIR" {
  echo "1.2.3" > .lua-version
  mkdir -p "$HOME"
  echo "2.0-home" > "${HOME}/.lua-version"
  LUAENV_DIR="$HOME" run luaenv-local
  assert_success "1.2.3"
}

@test "sets local version" {
  mkdir -p "${LUAENV_ROOT}/versions/1.2.3"
  run luaenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .lua-version)" = "1.2.3" ]
}

@test "changes local version" {
  echo "1.0-pre" > .lua-version
  mkdir -p "${LUAENV_ROOT}/versions/1.2.3"
  run luaenv-local
  assert_success "1.0-pre"
  run luaenv-local 1.2.3
  assert_success ""
  assert [ "$(cat .lua-version)" = "1.2.3" ]
}

@test "renames .luaenv-version to .lua-version" {
  echo "1.8.7" > .luaenv-version
  mkdir -p "${LUAENV_ROOT}/versions/1.9.3"
  run luaenv-local
  assert_success "1.8.7"
  run luaenv-local "1.9.3"
  assert_success
  assert_output <<OUT
luaenv: removed existing \`.luaenv-version' file and migrated
       local version specification to \`.lua-version' file
OUT
  assert [ ! -e .luaenv-version ]
  assert [ "$(cat .lua-version)" = "1.9.3" ]
}

@test "doesn't rename .luaenv-version if changing the version failed" {
  echo "1.8.7" > .luaenv-version
  assert [ ! -e "${LUAENV_ROOT}/versions/1.9.3" ]
  run luaenv-local "1.9.3"
  assert_failure "luaenv: version \`1.9.3' not installed"
  assert [ ! -e .lua-version ]
  assert [ "$(cat .luaenv-version)" = "1.8.7" ]
}

@test "unsets local version" {
  touch .lua-version
  run luaenv-local --unset
  assert_success ""
  assert [ ! -e .luaenv-version ]
}

@test "unsets alternate version file" {
  touch .luaenv-version
  run luaenv-local --unset
  assert_success ""
  assert [ ! -e .luaenv-version ]
}
