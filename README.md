# Marc to Argot transformer
 
## Installation
1. Clone repo
2. `bundle install`
3. `rake install`

## Basic Use
`mta help create`
List of options for the create command

`mta create <collection> <input> <output>`
1. Collection 

## Common options

* Change output file, `-s output_file=<path/to/file>`
* Pretty print the json, `-s argot_writer.pretty_print=true`
* Use Marc XML, `-s marc_source.type=xml`


## Configurations

### Settings
In addition to command-line options, you can permanently set the settings in the **settings* block of your institution's config file.
```
# threads
provide 'processing_thread_pool', 3

# default output file (placed into the directory where you run the script)
provide "output_file", "~/argot_out.json"

# set to true for pretty JSON output
provide "argot_writer.pretty_print", false

# Comment out/remove if using marc binary
provide "marc_source.type", "xml"

# Prevent argot.rb from processing these fields (you will need to provide your own logic)
provide "override", %w(id local_id institution cataloged_date items)
```

### Insitutuional Specs
Spec files define the map between MARC fields and the Argot model. Each institution will manage their own spec file, located in `configs/<inst>/spec.yml`.
Alternatively, you can pass a spec file as a traject setting: `-s spec_file=<path/to/file>`
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

These spec files are uniquely configured to work with the argot.rb traject configuration. Essentially, these are centralized, agreed upon conventions for each institution.

### Overriding default conventions
The institutional (or collection) configs can override default argot.rb behavior by adding and argot attribute to the "override" setting. Then provide you're own logic for that attribute. For example, default behavior for the institution attribute is to add each institutuion to the record:

```
to_field "institution" do |rec, acc|
  inst = %w(unc duke nccu ncsu)
  acc.concat(inst)
end
```

But you can override this for you own config:
```
provide "override", %w(institution)

to_field "institution", literal("unc")
```

