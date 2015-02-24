# Test Lingon against the simplest project possible.
# Covers: Building, Concatenating, Serving over http

# Before each spec
setup() {
  # cd to the basic test project
  CWD="tests/system/cli"
  cd $CWD

  rm -rf tmp/
  mkdir tmp/
  pushd tmp/ > /dev/null
  git init . > /dev/null
  echo '{"version": "0.0.1"}' > package.json
  git add .
  git commit -m "Initial commit" > /dev/null
  popd > /dev/null
}

@test "cli: prints usage" {
  # running autoversion with no argument
  run ./autoversion.js
  [ "$output" = "Usage: autoversion version|patch|minor|major" ]

  # running autoversion with random, non-supported argument
  run ./autoversion.js help
  [ "$output" = "Usage: autoversion version|patch|minor|major" ]
}

@test "cli: prints version" {
  run ./autoversion.js version
  [ "$output" = "0.0.1" ]
}

@test "cli: increases PATCH version" {
  run ./autoversion.js patch
  [ "${lines[0]}" = "Increased PATCH version. New version: 0.0.2" ]
  [ "${lines[1]}" = "Increased ANY version. New version: 0.0.2" ]
  [ "${lines[2]}" = "All done!" ]

  run cat tmp/package.json
  [ "$output" = '{"version":"0.0.2"}' ]
}

@test "cli: increases MINOR version" {
  run ./autoversion.js minor
  [ "${lines[0]}" = "Increased MINOR version. New version: 0.1.0" ]
  [ "${lines[1]}" = "Increased ANY version. New version: 0.1.0" ]
  [ "${lines[2]}" = "All done!" ]

  run cat tmp/package.json
  cat tmp/package.json
  [ "$output" = '{"version":"0.1.0"}' ]
}

@test "cli: increases MAJOR version" {
  run ./autoversion.js major
  [ "${lines[0]}" = "Increased MAJOR version. New version: 1.0.0" ]
  [ "${lines[1]}" = "Increased ANY version. New version: 1.0.0" ]
  [ "${lines[2]}" = "All done!" ]

  run cat tmp/package.json
  cat tmp/package.json
  [ "$output" = '{"version":"1.0.0"}' ]
}
