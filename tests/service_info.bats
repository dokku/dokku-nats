#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:info) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:info"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:info) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:info" not_existing_service
  assert_contains "${lines[*]}" "service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:info) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:info" l
  local password="$(cat "$PLUGIN_DATA_ROOT/l/PASSWORD")"
  assert_contains "${lines[*]}" "nats://l:$password@dokku-nats-l:4222"
}

@test "($PLUGIN_COMMAND_PREFIX:info) replaces underscores by dash in hostname" {
  dokku "$PLUGIN_COMMAND_PREFIX:create" test_with_underscores
  run dokku "$PLUGIN_COMMAND_PREFIX:info" test_with_underscores
  local password="$(cat "$PLUGIN_DATA_ROOT/test_with_underscores/PASSWORD")"
  assert_contains "${lines[*]}" "nats://test_with_underscores:$password@dokku-nats-test-with-underscores:4222"
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" test_with_underscores
}

@test "($PLUGIN_COMMAND_PREFIX:info) success with flag" {
  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --dsn
  local password="$(cat "$PLUGIN_DATA_ROOT/l/PASSWORD")"
  assert_output "nats://l:$password@dokku-nats-l:4222"

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --config-dir
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --data-dir
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --dsn
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --exposed-ports
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --id
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --links
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --status
  assert_success

  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --version
  assert_success
}

@test "($PLUGIN_COMMAND_PREFIX:info) error when invalid flag" {
  run dokku "$PLUGIN_COMMAND_PREFIX:info" l --invalid-flag
  assert_failure
}
