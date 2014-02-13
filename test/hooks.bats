#!/usr/bin/env bats

load test_helper

create_hook() {
  mkdir -p "$1/$2"
  touch "$1/$2/$3"
}

@test "prints usage help given no argument" {
  run luaenv-hooks
  assert_failure "Usage: luaenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${LUAENV_TEST_DIR}/luaenv.d"
  path2="${LUAENV_TEST_DIR}/etc/luaenv_hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path1" exec "ahoy.bash"
  create_hook "$path1" exec "invalid.sh"
  create_hook "$path1" which "boom.bash"
  create_hook "$path2" exec "bueno.bash"

  LUAENV_HOOK_PATH="$path1:$path2" run luaenv-hooks exec
  assert_success
  assert_output <<OUT
${LUAENV_TEST_DIR}/luaenv.d/exec/ahoy.bash
${LUAENV_TEST_DIR}/luaenv.d/exec/hello.bash
${LUAENV_TEST_DIR}/etc/luaenv_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${LUAENV_TEST_DIR}/my hooks/luaenv.d"
  path2="${LUAENV_TEST_DIR}/etc/luaenv hooks"
  create_hook "$path1" exec "hello.bash"
  create_hook "$path2" exec "ahoy.bash"

  LUAENV_HOOK_PATH="$path1:$path2" run luaenv-hooks exec
  assert_success
  assert_output <<OUT
${LUAENV_TEST_DIR}/my hooks/luaenv.d/exec/hello.bash
${LUAENV_TEST_DIR}/etc/luaenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  path="${LUAENV_TEST_DIR}/luaenv.d"
  create_hook "$path" exec "hello.bash"
  mkdir -p "$HOME"

  LUAENV_HOOK_PATH="${HOME}/../luaenv.d" run luaenv-hooks exec
  assert_success "${LUAENV_TEST_DIR}/luaenv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${LUAENV_TEST_DIR}/luaenv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"

  LUAENV_HOOK_PATH="$path" run luaenv-hooks exec
  assert_success "${HOME}/hola.bash"
}
