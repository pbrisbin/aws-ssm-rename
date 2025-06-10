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
    --type String
}

ls_parameters() {
  aws ssm get-parameters-by-path \
    --path "$SSM_NAMESPACE/" \
    --recursive \
    --query "Parameters[].[Name]" \
    --output text
}

teardown() {
  ls_parameters | while read -r param; do
    aws ssm delete-parameter --name "$param"
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
$SSM_NAMESPACE/TEST1
$SSM_NAMESPACE/TEST2
$SSM_NAMESPACE/skip
EOM
}
