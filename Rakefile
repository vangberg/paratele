task :default => :test

task :test do
  require "cutest"
  Cutest.run(Dir["test/tele.rb"])
end

namespace :gem do
  task :build do
    `erb paratele.gemspec.erb > paratele.gemspec && gem build paratele.gemspec`
  end
end
