# danger-periphery

[![Test](https://github.com/manicmaniac/danger-periphery/actions/workflows/test.yml/badge.svg)](https://github.com/manicmaniac/danger-periphery/actions/workflows/test.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/1006dd155fc527b2b687/maintainability)](https://codeclimate.com/github/manicmaniac/danger-periphery/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/1006dd155fc527b2b687/test_coverage)](https://codeclimate.com/github/manicmaniac/danger-periphery/test_coverage)
[![Gem Version](https://badge.fury.io/rb/danger-periphery.svg)](https://badge.fury.io/rb/danger-periphery)

A Danger plugin to detect unused codes.

<img width="899" alt="image" src="https://user-images.githubusercontent.com/1672393/181256005-40842f99-d504-4be8-a0e5-5df144f939d7.png">

## Installation

You need to install [Periphery](https://github.com/peripheryapp/periphery) beforehand.

Write the following code in your Gemfile.

```ruby
gem "danger-periphery"
```

## Usage

If you already have `.periphery.yml`, the easiest way to use is just add this to your Dangerfile.

```ruby
periphery.scan
```

You can specify the path to executable in this way.

```ruby
periphery.binary_path = "bin/periphery"
```

You can pass command line options to `periphery.scan` like the following.
See `periphery scan -h` for available options.

Note that `build_args` option is a special option that does not exist in Periphery but the arguments are passed down to `periphery` after an argument terminator (`--`).

```ruby
periphery.scan(
  project: "Foo.xcodeproj",
  schemes: ["foo", "bar"],
  targets: "foo",
  clean_build: true,
  build_args: "-sdk iphonesimulator"
)
```

By default, `danger-periphery` scans all files in the specified targets and reports problems only in added, modified and renamed files.
You can make `danger-periphery` report problems in all files by setting `scan_all_files` to true.

```ruby
periphery.scan_all_files = true
periphery.scan
```

You can force `danger-periphery` treat all warnings as errors by changing `warning_as_error` flag.

```ruby
periphery.warning_as_error = true
periphery.scan
```

## Advanced Usage

### Skip building for faster analysis

Let's say that your project already have workflow to run test like the following GitHub Actions workflow.

```yaml
# .github/workflows/test.yml

steps:
  - name: Run Danger
    run: bundle exec danger
  - name: Run test
    run: xcodebuild test -project Foo.xcodeproj -scheme foo -sdk iphonesimulator -arch arm64
```

In this case, Periphery can reuse the index store generated by the previous build.

To enable this feature, you need to give `index_store_path` to the generated index store, and set `skip_build` to true.

```ruby
# Dangerfile

periphery.scan(
  project: "Foo.xcodeproj",
  schemes: "foo",
  targets: "foo",
  skip_build: true,
  index_store_path: 'DerivedData/Index.noindex/DataStore' # 'DerivedData/Index/DataStore' in Xcode 13 or earlier.
)
```

Then do not forget to pass `-derivedDataPath` option to `xcodebuild`, and reorder steps.

```yaml
# .github/workflows/test.yml

steps:
  - name: Run test
    run: xcodebuild test -project Foo.xcodeproj -scheme foo -sdk iphonesimulator -arch arm64 -derivedDataPath DerivedData
  - name: Run Danger
    run: bundle exec danger
```

### Postprocess warnings by passing block to `#scan`

You can modify warnings as you like by passing a block to `scan`.
`scan` takes a block that receives `ScanResult` instance as arguments.
Each `ScanResult` instance corresponds with each entry of Danger warnings.
If that block returns falsy value, danger-periphery suppresses the corresponding warning.

For example, if you want your team members to be careful with warnings, the following code may work.

```ruby
periphery.scan do |violation|
  violation.message = "Pay attention please! #{violation.message}"
end
```

For another example, if you want to suppress warnings complaining about unused parameter of many of `didChangeValue(_ sender: Any)` methods, you can suppress this kind of warnings in the following way.

```ruby
periphery.scan do |violation|
  !violation.message.match(/Parameter 'sender' is unused/)
end
```

### Install Periphery in Dangerfile

Although I recommend you to install Periphery binary on your own, `danger-periphery` provides a method to install Periphery in Dangerfile.

```ruby
periphery.install
periphery.scan
```

Note that `periphery.install` also changes `periphery.binary_path` so that you don't need to specify the installed file path.

If you want to install the specific version of Periphery to the specific path with overwriting an existing file, add options like this.

```ruby
periphery.install version: '2.10.0', path: 'bin/periphery', force: true
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake periphery:install` to install Periphery.
4. Run `bundle exec rake spec` to run the tests.
5. Use `bundle exec guard` to automatically have tests run as you make changes.
6. Make your changes.
