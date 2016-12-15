# Scytale
Marc to Argot transformer
 
## Requirements
[Traject](https://github.com/traject/traject)

Run command 
```traject -c marc-to-argot/argot.rb <marc-file>```

Optionally, add in an institutional config
```traject -c marc-to-argot/config/<inst>.rb -c marc-to-argot/argot.rb <marc-file>```

Note:
This was a first attempt at getting vernacular to play nice. Essentially,
the "create_vernacular_bag" makes a hash for all matching 880 fields.

When the fields are processed into a nested structure (i.e., create_title_object)
it reaches into that bag and pulls out the matching vernacular object, utilizing
subfield 6 to create a match.

