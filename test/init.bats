#!/usr/bin/env bats

load test_helper

@test "creates shims and versions directories" {
  assert [ ! -d "${LUAENV_ROOT}/shims" ]
  assert [ ! -d "${LUAENV_ROOT}/versions" ]
  run luaenv-init -
  assert_success
  assert [ -d "${LUAENV_ROOT}/shims" ]
  assert [ -d "${LUAENV_ROOT}/versions" ]
}

@test "auto rehash" {
  run luaenv-init -
  assert_success
  assert_line "luaenv rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run luaenv-init - bash
  assert_success
  assert_line "source '${root}/libexec/../completions/luaenv.bash'"
}

@test "detect parent shell" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  SHELL=/bin/false run luaenv-init -
  assert_success
  assert_line "export LUAENV_SHELL=bash"
}

@test "setup shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run luaenv-init - fish
  assert_success
  assert_line ". '${root}/libexec/../completions/luaenv.fish'"
}

@test "fish instructions" {
  run luaenv-init fish
  assert [ "$status" -eq 1 ]
  assert_line 'status --is-interactive; and . (luaenv init -|psub)'
}

@test "option to skip rehash" {
  run luaenv-init - --no-rehash
  assert_success
  refute_line "luaenv rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run luaenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${LUAENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run luaenv-init - fish
  assert_success
  assert_line 0 "setenv PATH '${LUAENV_ROOT}/shims' \$PATH"
}

@test "doesn't add shims to PATH more than once" {
  export PATH="${LUAENV_ROOT}/shims:$PATH"
  run luaenv-init - bash
  assert_success
  refute_line 'export PATH="'${LUAENV_ROOT}'/shims:${PATH}"'
}

@test "doesn't add shims to PATH more than once (fish)" {
  export PATH="${LUAENV_ROOT}/shims:$PATH"
  run luaenv-init - fish
  assert_success
  refute_line 'setenv PATH "'${LUAENV_ROOT}'/shims" $PATH ;'
}
