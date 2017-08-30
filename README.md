# Marc to Argot transformer

Converts MARC input to Argot, TRLN Discovery's shared ingest format.


## CI Status

[![branch master](https://travis-ci.org/trln/marc-to-argot.svg?branch=master)](https://travis-ci.org/trln/marc-to-argot)

## Installation
1. Clone repo
2. `bundle install` - make sure you have the necessary repos
3. `rake install` - create and install the gem

## Basic Use
`mta help create`
List of options for the create command

`mta create <collection> <input> <output>`
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


## Insitutuional Specs
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
Each collection has a traject_config.rb file. This represents the processing of the marc fields to argot attrbitues. `argot/traject_config.rb` is the centralized, agreed upon conventions for each institution.

### Overriding default conventions
But each institution has the option of completely override the default conventions as they see fit. Create an overrides.yml file in the collection folder. Each key in the yaml file will not be processed by `argot/traject_config.rb`. Note, you will need to provide your own login in the collection's traject_config file. For example:

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

### Writing Tests

Tests that involve checking that the results of transforming your institutional MARC to Argot are correct involve:

  * Selecting a file containing representative record(s) in MARC format.
  * copying that file with a meaningful name to `spec/[collecttion]/[name].[extension]`
  * in your test (in `spec/marc_to_argot_spec.rb` for now, we should probably break this into multiple files as the number of tests grow), call `TrajectRunTest.run_traject([collection], [name], [extension])` -- this will load the MARC file, run your Traject configuration over it, and return the result as a String, which you can then parse and have expectations about.  We'll probably need to write some utility classes for doing that stuff, and e.g. hook in the validator from the `argot-ruby` gem.

Run tests with `rake spec`
