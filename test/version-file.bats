#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$LUAENV_TEST_DIR"
  cd "$LUAENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${LUAENV_ROOT}/version" ]
  assert [ ! -e ".lua-version" ]
  run luaenv-version-file
  assert_success "${LUAENV_ROOT}/version"
}

@test "detects 'global' file" {
  create_file "${LUAENV_ROOT}/global"
  run luaenv-version-file
  assert_success "${LUAENV_ROOT}/global"
}

@test "detects 'default' file" {
  create_file "${LUAENV_ROOT}/default"
  run luaenv-version-file
  assert_success "${LUAENV_ROOT}/default"
}

@test "'version' has precedence over 'global' and 'default'" {
  create_file "${LUAENV_ROOT}/version"
  create_file "${LUAENV_ROOT}/global"
  create_file "${LUAENV_ROOT}/default"
  run luaenv-version-file
  assert_success "${LUAENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".lua-version"
  run luaenv-version-file
  assert_success "${LUAENV_TEST_DIR}/.lua-version"
}

@test "legacy file in current directory" {
  create_file ".luaenv-version"
  run luaenv-version-file
  assert_success "${LUAENV_TEST_DIR}/.luaenv-version"
}

@test ".lua-version has precedence over legacy file" {
  create_file ".lua-version"
  create_file ".luaenv-version"
  run luaenv-version-file
  assert_success "${LUAENV_TEST_DIR}/.lua-version"
}

@test "in parent directory" {
  create_file ".lua-version"
  mkdir -p project
  cd project
  run luaenv-version-file
  assert_success "${LUAENV_TEST_DIR}/.lua-version"
}

@test "topmost file has precedence" {
  create_file ".lua-version"
  create_file "project/.lua-version"
  cd project
  run luaenv-version-file
  assert_success "${LUAENV_TEST_DIR}/project/.lua-version"
}

@test "legacy file has precedence if higher" {
  create_file ".lua-version"
  create_file "project/.luaenv-version"
  cd project
  run luaenv-version-file
  assert_success "${LUAENV_TEST_DIR}/project/.luaenv-version"
}

@test "LUAENV_DIR has precedence over PWD" {
  create_file "widget/.lua-version"
  create_file "project/.lua-version"
  cd project
  LUAENV_DIR="${LUAENV_TEST_DIR}/widget" run luaenv-version-file
  assert_success "${LUAENV_TEST_DIR}/widget/.lua-version"
}

@test "PWD is searched if LUAENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.lua-version"
  cd project
  LUAENV_DIR="${LUAENV_TEST_DIR}/widget/blank" run luaenv-version-file
  assert_success "${LUAENV_TEST_DIR}/project/.lua-version"
}
