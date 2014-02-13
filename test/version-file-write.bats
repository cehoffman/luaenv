#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$LUAENV_TEST_DIR"
  cd "$LUAENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run luaenv-version-file-write
  assert_failure "Usage: luaenv version-file-write <file> <version>"
  run luaenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".lua-version" ]
  run luaenv-version-file-write ".lua-version" "1.8.7"
  assert_failure "luaenv: version \`1.8.7' not installed"
  assert [ ! -e ".lua-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${LUAENV_ROOT}/versions/1.8.7"
  assert [ ! -e "my-version" ]
  run luaenv-version-file-write "${PWD}/my-version" "1.8.7"
  assert_success ""
  assert [ "$(cat my-version)" = "1.8.7" ]
}
