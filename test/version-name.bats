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
  run luaenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  LUAENV_VERSION=system run luaenv-version-name
  assert_success "system"
}

@test "LUAENV_VERSION has precedence over local" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > ".lua-version" <<<"1.8.7"
  run luaenv-version-name
  assert_success "1.8.7"

  LUAENV_VERSION=1.9.3 run luaenv-version-name
  assert_success "1.9.3"
}

@test "local file has precedence over global" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > "${LUAENV_ROOT}/version" <<<"1.8.7"
  run luaenv-version-name
  assert_success "1.8.7"

  cat > ".lua-version" <<<"1.9.3"
  run luaenv-version-name
  assert_success "1.9.3"
}

@test "missing version" {
  LUAENV_VERSION=1.2 run luaenv-version-name
  assert_failure "luaenv: version \`1.2' is not installed"
}

@test "version with prefix in name" {
  create_version "1.8.7"
  cat > ".lua-version" <<<"lua-1.8.7"
  run luaenv-version-name
  assert_success
  assert_output "1.8.7"
}
