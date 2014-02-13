#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${LUAENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$LUAENV_TEST_DIR"
  cd "$LUAENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${LUAENV_ROOT}/versions" ]
  run luaenv-version
  assert_success "system (set by ${LUAENV_ROOT}/version)"
}

@test "set by LUAENV_VERSION" {
  create_version "1.9.3"
  LUAENV_VERSION=1.9.3 run luaenv-version
  assert_success "1.9.3 (set by LUAENV_VERSION environment variable)"
}

@test "set by local file" {
  create_version "1.9.3"
  cat > ".lua-version" <<<"1.9.3"
  run luaenv-version
  assert_success "1.9.3 (set by ${PWD}/.lua-version)"
}

@test "set by global file" {
  create_version "1.9.3"
  cat > "${LUAENV_ROOT}/version" <<<"1.9.3"
  run luaenv-version
  assert_success "1.9.3 (set by ${LUAENV_ROOT}/version)"
}
