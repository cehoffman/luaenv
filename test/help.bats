#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run luaenv-help
  assert_success
  assert_line "Usage: luaenv <command> [<args>]"
  assert_line "Some useful luaenv commands are:"
}

@test "invalid command" {
  run luaenv-help hello
  assert_failure "luaenv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${LUAENV_TEST_DIR}/bin"
  cat > "${LUAENV_TEST_DIR}/bin/luaenv-hello" <<SH
#!shebang
# Usage: luaenv hello <world>
# Summary: Says "hello" to you, from luaenv
# This command is useful for saying hello.
echo hello
SH

  run luaenv-help hello
  assert_success
  assert_output <<SH
Usage: luaenv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${LUAENV_TEST_DIR}/bin"
  cat > "${LUAENV_TEST_DIR}/bin/luaenv-hello" <<SH
#!shebang
# Usage: luaenv hello <world>
# Summary: Says "hello" to you, from luaenv
echo hello
SH

  run luaenv-help hello
  assert_success
  assert_output <<SH
Usage: luaenv hello <world>

Says "hello" to you, from luaenv
SH
}

@test "extracts only usage" {
  mkdir -p "${LUAENV_TEST_DIR}/bin"
  cat > "${LUAENV_TEST_DIR}/bin/luaenv-hello" <<SH
#!shebang
# Usage: luaenv hello <world>
# Summary: Says "hello" to you, from luaenv
# This extended help won't be shown.
echo hello
SH

  run luaenv-help --usage hello
  assert_success "Usage: luaenv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${LUAENV_TEST_DIR}/bin"
  cat > "${LUAENV_TEST_DIR}/bin/luaenv-hello" <<SH
#!shebang
# Usage: luaenv hello <world>
#        luaenv hi [everybody]
#        luaenv hola --translate
# Summary: Says "hello" to you, from luaenv
# Help text.
echo hello
SH

  run luaenv-help hello
  assert_success
  assert_output <<SH
Usage: luaenv hello <world>
       luaenv hi [everybody]
       luaenv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${LUAENV_TEST_DIR}/bin"
  cat > "${LUAENV_TEST_DIR}/bin/luaenv-hello" <<SH
#!shebang
# Usage: luaenv hello <world>
# Summary: Says "hello" to you, from luaenv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run luaenv-help hello
  assert_success
  assert_output <<SH
Usage: luaenv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
