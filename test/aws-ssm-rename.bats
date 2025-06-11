setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  # Ensure we can call aws-ssm-rename
  export PATH="$PWD/bin:$PATH"

  export SSM_NAMESPACE="/tmp/aws-ssm-rename-tests/$$"
}

put_parameter() {
  aws ssm put-parameter \
    --name "$SSM_NAMESPACE/$1" \
    --value "$2" \
    --type String >/dev/null
}

get_parameter() {
  aws ssm get-parameter \
    --name "$SSM_NAMESPACE/$1" \
    --query "Parameter.Value" \
    --output text
}

ls_parameters() {
  aws ssm get-parameters-by-path \
    --path "$SSM_NAMESPACE/" \
    --recursive \
    --query "Parameters[].[Name]" \
    --output text |
    sed 's|^'"$SSM_NAMESPACE"'||'
}

teardown() {
  ls_parameters | while read -r param; do
    aws ssm delete-parameter --name "$SSM_NAMESPACE$param"
  done
}

@test "help" {
  run aws-ssm-rename --help
  assert_output <<'EOM'
     Usage:
       aws-ssm-rename [options] <expression> <replacement> <parameter>...

     Rename AWS SSM parameters.

     Options:
      -v, --verbose          explain what is being done
      -n, --no-act           do not make any changes
      -a, --all              replace all ocurrences
      -o, --no-overwrite     don't overwrite existing parameters
      -i, --interactive      prompt before overwrite
      -g, --no-glob          don't match parameters as globs

      -h, --help             display this help
      -V, --version          display version


     rename(1) features not implemented:
      -s, --symlink
      -l, --last

     For more details see aws-ssm-rename(1).
EOM
}

@test "simple rename" {
  put_parameter "test1" "1"
  put_parameter "test2" "2"
  put_parameter "skip" "3"

  run aws-ssm-rename "test" "TEST" "$SSM_NAMESPACE/test*"
  assert_success
  assert_output ""

  run ls_parameters
  assert_output <<EOM
/TEST1
/TEST2
/skip
EOM
}

@test "man-page example foo" {
  put_parameter "foo1" "1"
  put_parameter "foo9" "2"
  put_parameter "foo10" "3"
  put_parameter "foo278" "4"

  run aws-ssm-rename "foo" "foo00" "$SSM_NAMESPACE/foo?"
  assert_success
  assert_output ""

  run aws-ssm-rename "foo" "foo0" "$SSM_NAMESPACE/foo??"
  assert_success
  assert_output ""

  run ls_parameters
  assert_output <<EOM
/foo001
/foo009
/foo010
/foo278
EOM
}

@test "man-page example dev/prod" {
  put_parameter "dev/parameter1" "d1"
  put_parameter "dev/parameter2" "d2"
  put_parameter "dev/parameter3" "d3"
  put_parameter "prod/parameter1" "p1"
  put_parameter "prod/parameter2" "p2"

  run aws-ssm-rename "/dev/" "/prod/" "$SSM_NAMESPACE/dev/*"
  assert_success
  assert_output ""

  run ls_parameters
  assert_output <<EOM
/prod/parameter1
/prod/parameter2
/prod/parameter3
EOM

  run get_parameter "prod/parameter1"
  assert_output "d1"

  run get_parameter "prod/parameter2"
  assert_output "d2"
}

@test "man-page example shortening" {
  put_parameter "parameter-with-long-name-1" "1"
  put_parameter "parameter-with-long-name-2" "2"
  put_parameter "parameter-with-long-name-3" "3"

  run aws-ssm-rename -- "-with-long-name" "" "$SSM_NAMESPACE/parameter-with-long-name-*"
  assert_success
  assert_output ""

  run ls_parameters
  assert_output <<EOM
/parameter-1
/parameter-2
/parameter-3
EOM
}

@test "with --no-overwrite" {
  put_parameter "foo" "1"
  put_parameter "bar" "2"

  run aws-ssm-rename --no-overwrite "foo" "bar" "$SSM_NAMESPACE/*"
  assert_success
  assert_output "Not overwriting existing parameter $SSM_NAMESPACE/bar"

  run ls_parameters
  assert_output <<EOM
/foo
/bar
EOM
}

@test "exits 4 if nothing renamed" {
  put_parameter "foo" "1"
  put_parameter "bar" "1"

  run aws-ssm-rename "baz" "bat" "$SSM_NAMESPACE/*"
  assert_failure 4
}
