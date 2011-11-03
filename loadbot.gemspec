GEM_FILES = %w{
  loadbot.gemspec
  lib/loadbot.rb
  config/loadbot.yml
}

Gem::Specification.new do |s|
  s.name = "loadbot"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Your Name Here!"]

  s.date = Date.today.to_s
  s.description = "This Adhearsion component gem has not yet been described."
  s.email = "noreply@example.com"

  s.files = GEM_FILES

  s.has_rdoc = false
  s.homepage = "http://adhearsion.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.2.0"
  s.summary = "This Adhearsion component gem has no summary."

  s.specification_version = 2
end
