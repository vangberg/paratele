require "shellwords"
require "open3"

ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

def root(*args)
  File.join(ROOT, *args)
end

def paratele(*args)
  sh("ruby #{root "bin/paratele"} #{Shellwords.join args}")
end

def sh(cmd)
  Open3.capture3(cmd)
end

test "`paratele run` without a config" do
  Dir.chdir("test") {
    out, err, status = paratele("run", "install", "production")

    assert err =~ /Couldn't find/
    assert_equal 1, status.exitstatus
  }
end

test "`paratele run` with missing recipes" do
  out, err, status = paratele("run", "deploy", "production", "-d", "test/tele.missing-recipes")

  assert_equal 1, status.exitstatus
  assert out =~ /db-1/
  assert out =~ /redis: .*\?/
  assert out !~ /cassandra: .*\?/
end

test "`paratele run` successful - production" do
  out, err, status = paratele("run", "install", "production", "-d", "test/tele.simple")

  assert_equal 0, status.exitstatus
  assert out =~ /db-1/
  assert out =~ /db-2/
  assert out =~ /redis: .*OK/
  assert out =~ /cdb: .*OK/
  assert out =~ /cassandra: .*OK/

  assert out !~ /sta-1/
end

test "`paratele run` successful - staging" do
  out, err, status = paratele("run", "install", "staging", "-d", "test/tele.simple")

  assert_equal 0, status.exitstatus
  assert out =~ /sta1/
  assert out =~ /redis: .*OK/

  assert out !~ /db-1/
  assert out !~ /db-2/
  assert out !~ /cdb:/
  assert out !~ /cassandra:/
end

test "`paratele run` with recipes missing a command" do
  out, err, status = paratele("run", "status", "production", "-d", "test/tele.simple")

  assert_equal 0, status.exitstatus
  assert out =~ /cassandra: .*\?/
  assert out =~ /cdb: .*OK/
  assert out =~ /redis: .*OK/
end

test "`paratele run` with errors" do
  out, err, status = paratele("run", "update", "production", "-d", "test/tele.simple")

  assert_equal 1, status.exitstatus

  assert out =~ /db-1/
  assert out =~ /cassandra: .*ERROR/
  assert err =~ /Updating Cassandra failed/
  assert out !~ /cdb:/

  assert out =~ /db-2/
  assert out =~ /redis: .*OK/
end

test "`paratele run` with specific server" do
  out, err, status = paratele("run", "install", "production:db-2", "-d", "test/tele.simple")

  assert_equal 0, status.exitstatus
  assert out !~ /sta-1/
  assert out !~ /db-1/
  assert out !~ /cassandra/
  assert out !~ /cdb/
  assert out =~ /db-2/
  assert out =~ /redis/
end

test "`paratele run` with multiple server" do
  out, err, status = paratele("run", "install", "production:db-2,db-1", "-d", "test/tele.simple")

  assert_equal 0, status.exitstatus
  assert out !~ /sta-1/
  assert out =~ /db-1/
  assert out =~ /db-2/
end

test "`paratele run -v`" do
  out, err, status = paratele("run", "update", "production", "-v", "-d", "test/tele.simple")

  assert err =~ /Redis succesfully updated/
  assert err =~ /Updating Cassandra failed/
  assert out !~ /Redis succesfully updated/
  assert out !~ /Updating Cassandra failed/
end

test "`paratele run -q`" do
  out, err, status = paratele("run", "update", "production", "-q", "-d", "test/tele.simple")

  assert err !~ /Redis succesfully updated/
  assert err !~ /Updating Cassandra failed/
  assert out !~ /Redis succesfully updated/
  assert out !~ /Updating Cassandra failed/
end
