module MarcToArgot
  # namespace for institution-specific macros to be used in Traject config files
  # In general, you put `extend MarcToArgot::Macros::[INSTITUTION]`
  # at the top of your traject configuration file, and you get access to any
  # method defined in your institution file, OR in the `Shared` module.
  module Macros
    autoload :Shared, 'marc_to_argot/macros/shared_macros'
    autoload :NCSU, 'marc_to_argot/macros/ncsu_macros'
    autoload :Duke, 'marc_to_argot/macros/duke_macros'
    autoload :UNC, 'marc_to_argot/macros/unc_macros'
    autoload :NCCU, 'marc_to_argot/macros/nccu_macros'
  end
end
