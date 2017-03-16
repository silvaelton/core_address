$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "core_address/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "core_address"
  s.version     = CoreAddress::VERSION
  s.authors     = ["Elton Silva"]
  s.email       = ["elton.chrls@gmail.com"]
  s.homepage    = "https://github.com/silvaelton/core_address.git"
  s.summary     = "Summary of CoreAddress."
  s.description = "Description of CoreAddress."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.2"
  s.add_dependency "pg"

end
