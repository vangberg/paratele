Gem::Specification.new do |s|
  s.name              = "paratele"
  s.version           = "0.2"
  s.summary           = "Provisioning at a distance"
  s.description       = "Tele is a small provisioning framework that allows you to run bash scripts on remote servers over SSH."
  s.authors           = ["Damian Janowski", "Michel Martens", "Harry Vangberg"]
  s.email             = ["djanowski@dimaion.com", "michel@soveran.com", "harry@vangberg.name"]
  s.homepage          = "http://github.com/vangberg/paratele"

  s.executables.push("paratele")

  s.add_dependency("clap")

  s.files = ["LICENSE", "README", "Rakefile", "bin/paratele", "paratele.gemspec", "test/tele.missing-recipes", "test/tele.rb", "test/tele.simple"]
end
