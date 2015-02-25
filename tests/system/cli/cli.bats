# Test Lingon against the simplest project possible.
# Covers: Building, Concatenating, Serving over http

# Before each spec
setup() {
  # cd to the basic test project
  cd $BATS_TEST_DIRNAME

  rm -rf tmp/
  mkdir tmp/
  pushd tmp/ > /dev/null
  git init . > /dev/null
  echo -e $'{\n  "version": "0.0.1"\n}' > package.json
  git add .
  git commit -m "Initial commit" > /dev/null
  popd > /dev/null
}

@test "cli: prints usage" {
  # running autoversion with no argument
  run ./autoversion.js
  [ $status -eq 0 ]
  [ $(expr "$output" : "Usage:") -ne 0 ]

  # running autoversion with random, non-supported argument
  run ./autoversion.js help
  [ $status -eq 0 ]
  [ $(expr "$output" : "Usage:") -ne 0 ]
}

@test "cli: prints version" {
  run ./autoversion.js version
  [ $status -eq 0 ]
  [ "$output" = "0.0.1" ]
}

@test "cli: does not increment if not confirming" {
  run bash -c "echo 'n' | ./autoversion.js patch"
  [ $status -eq 1 ]

  [ "${lines[0]}" = "New version will be 0.0.2" ]
  [ "${lines[1]}" = "Do you want to continue? [y/n] Aborting!" ]

  run cat tmp/package.json
  [ "$output" = $'{\n  "version": "0.0.1"\n}' ]
}

@test "cli: increments PATCH version (confirm \"y\")" {
  run bash -c "echo 'y' | ./autoversion.js patch"
  [ $status -eq 0 ]

  [ "${lines[0]}" = "New version will be 0.0.2" ]
  [ "${lines[1]}" = "Do you want to continue? [y/n] Incremented PATCH version. New version: 0.0.2" ]
  [ "${lines[2]}" = "Incremented ANY version. New version: 0.0.2" ]
  [ "${lines[3]}" = "All done!" ]

  run cat tmp/package.json
  [ "$output" = $'{\n  "version": "0.0.2"\n}' ]
}

@test "cli: increments PATCH version (confirm \"yes\")" {
  run bash -c "echo 'yes' | ./autoversion.js patch"
  [ $status -eq 0 ]

  [ "${lines[0]}" = "New version will be 0.0.2" ]
  [ "${lines[1]}" = "Do you want to continue? [y/n] Incremented PATCH version. New version: 0.0.2" ]
  [ "${lines[2]}" = "Incremented ANY version. New version: 0.0.2" ]
  [ "${lines[3]}" = "All done!" ]


  run cat tmp/package.json
  [ "$output" = $'{\n  "version": "0.0.2"\n}' ]
}

@test "cli: increments MINOR version (autoaccept --yes)" {
  run ./autoversion.js minor --yes
  [ $status -eq 0 ]
  [ "${lines[0]}" = "Incremented MINOR version. New version: 0.1.0" ]
  [ "${lines[1]}" = "Incremented ANY version. New version: 0.1.0" ]
  [ "${lines[2]}" = "All done!" ]

  run cat tmp/package.json
  cat tmp/package.json
  [ "$output" = $'{\n  "version": "0.1.0"\n}' ]
}

@test "cli: increments MAJOR version (autoaccept -y)" {
  run ./autoversion.js major -y
  [ $status -eq 0 ]
  [ "${lines[0]}" = "Incremented MAJOR version. New version: 1.0.0" ]
  [ "${lines[1]}" = "Incremented ANY version. New version: 1.0.0" ]
  [ "${lines[2]}" = "All done!" ]

  run cat tmp/package.json
  cat tmp/package.json
  [ "$output" = $'{\n  "version": "1.0.0"\n}' ]
}
