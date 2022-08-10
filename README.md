# Marc to Argot transformer

Converts MARC input to Argot, TRLN Discovery's shared ingest format.

The Argot format is documented at
https://github.com/trln/data-documentation/tree/master/argot

## CI Status

[![branch main ](https://github.com/trln/marc-to-argot/actions/workflows/ruby.yml/badge.svg)](https://github.com/trln/marc-to-argot/actions/workflows/ruby.yml)

## Installation

1. Clone repo
2. `bundle install`
3. (optional) `rake install` - create and install the gem
4. (alternate) prepend all commands below with `bundle exec`

(3) installs the gem globally, e.g. puts the `mta` executable on your path, and
may be appropriate for many circumstances; if you are developing this gem, and
may want to compare different versions, etc. the `bundle exec` approach in (4)
will probably serve your needs.

## Basic Use

    $ mta help create

List of options for the create command

    $ mta create <collection> <input> <output>

1. `<collection>` = the name of the collection to use (e.g., asp | unc | duke | ncsu)
2. `<input>` = the input marc file
3. `<output>` = the output file

### Options

| Name | Flag | Type | Default | Options |
| ---- | ---- | ---- | ---- | ---- |
| Marc file type | -t | string | xml | xml, json, binary |
| Marc encoding | -e | string | UTF-8 | UTF-8, MARC-8 |
| Pretty print | -p | boolean | false | |
| Spec file | -s | string | uses the `<collection>` variable | Can be a collection name or a file path. If the collection or file is not found it will default to argot/marc_specs.yml |
| Processing Thread Pool | -z | integer | 3 | integer |

## Institutional Specs

Spec files define the map between MARC fields and the Argot model. Each institution will manage their own spec file, located in `lib/data/<inst>/marc_specs.yml`.
**NOTE:** Each attribute in the yaml file should either be an array of Marc specs **OR** a hash of nested attributes

* Array of marc values:
```
imprint:
  - 260abcefg
  - 262abcde
  - 264abc
```
* Nested values:
```
isbn:
  primary:
    - 020a
  other: 
    - 020z
    - 776z
```
* **INCORRECT!!!**
```
isbn: 020a
```

These spec files are uniquely configured to work with the argot/traject_config.rb file. 

## Traject Config Files

Each collection has a traject_config.rb file at `lib/data/<collection name>/`.
This represents the processing of the marc fields to argot attributes.

`argot/traject_config.rb` is the centralized, agreed upon conventions for each
institution, but can be overridden by a collection-specific configuration.

### Overriding default conventions

Basic overrides can be created in the form of an `overrides.yml` file in the collection folder (alongside the relevant `traject_config.rb` file). Keys appearing
in the override file are ignored by the shared `argot/traject_config.rb` and left to be filled in by `<collection name>/traject_config.rb`

For example:

#### Default (argot/traject_config.rb)

```
to_field "institution" do |rec, acc|
  inst = %w(unc duke nccu ncsu)
  acc.concat(inst)
end
```

#### Overridden (duke/traject_config.rb)
```
to_field "institution", literal("duke")
```

#### Marked as overridden in the duke/overrides.yml file
```
- id
- institution
- items
```

In this example, any records processed in the `duke` collection will have their `institution` key in the output argot set to `"duke"`.

### Writing Tests

Tests that involve checking that the results of transforming your institutional MARC to Argot are correct involve:

  * Selecting a file containing representative record(s) in MARC format.
  * copying that file with a meaningful name to `spec/[collection]/[name].[extension]`
  * in your test (in `spec/<collection name>/spec_(thing you are testing)rb`)
    you can call `TrajectRunTest.run_traject([collection], [name], [extension])` to get the result of running your collection's transformations on the relevant file as a string; use `run_traject_json` (with the same arguments) to parse the resulting string as JSON -- this is usually easier to work with.

Run tests with `rspec`, e.g.

    $ bundle exec rspec

## Using a container for development

The `Dockerfile` in the directory specifies a container based on the official
ruby images, defaulting to version 2.7. A simple build is thus:

    $ docker build . -t mta:current

And run via

    $ docker run -it --rm -v $(pwd):/app mta:current

All gems should be installed already by the build process, but note that the presence of a `Gemfile.lock` in the directory may interfere with that.

If you want to try your changes in a different version of Ruby, provide the `RUBY_VERSION` build arg:

    $ docker build . --build-arg RUBY_VERSION=3.1 -t mta:current

See the `Dockerfile` for more details.
