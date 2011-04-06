require "shellwords"
require "open3"

ROOT = File.expand_path(File.join(File.dirname(__FILE__), ".."))

def root(*args)
  File.join(ROOT, *args)
end

def tele(*args)
  sh("ruby #{root "bin/paratele"} #{Shellwords.join args}")
end

def sh(cmd)
  Open3.capture3(cmd)
end

prepare do
  `rm -rf /tmp/tele`
  `mkdir /tmp/tele`
end

test "`tele run` without a config" do
  out, err, status = tele("run", "install")

  assert err =~ /Couldn't find/
  assert_equal 1, status.exitstatus
end

test "`tele run` with missing recipes" do
  out, err, status = tele("run", "deploy", "-d", "test/.tele.missing-recipes")

  assert_equal 1, status.exitstatus
  assert out =~ /db-1/
  assert out =~ /redis: .*\?/
  assert out !~ /cassandra: .*\?/
end

test "`tele run` successful" do
  out, err, status = tele("run", "install", "-d", "test/.tele.simple")

  assert_equal 0, status.exitstatus
  assert out =~ /db-1/
  assert out =~ /db-2/
  assert out =~ /redis: .*OK/
  assert out =~ /cdb: .*OK/
  assert out =~ /cassandra: .*OK/
end

test "`tele run` with recipes missing a command" do
  out, err, status = tele("run", "status", "-d", "test/.tele.simple")

  assert_equal 0, status.exitstatus
  assert out =~ /cassandra: .*\?/
  assert out =~ /cdb: .*OK/
  assert out =~ /redis: .*OK/
end

test "`tele run` with errors" do
  out, err, status = tele("run", "update", "-d", "test/.tele.simple")

  assert_equal 1, status.exitstatus

  assert out =~ /db-1/
  assert out =~ /cassandra: .*ERROR/
  assert err =~ /Updating Cassandra failed/
  assert out !~ /cdb:/

  assert out =~ /db-2/
  assert out =~ /redis: .*OK/
end

test "`tele run` with specific server" do
  out, err, status = tele("run", "install", "db-2", "-d", "test/.tele.simple")

  assert_equal 0, status.exitstatus
  assert out !~ /db-1/
  assert out !~ /cassandra/
  assert out !~ /cdb/
  assert out =~ /db-2/
  assert out =~ /redis/
end

test "`tele run` with multiple server" do
  out, err, status = tele("run", "install", "db-2,db-1", "-d", "test/.tele.simple")

  assert_equal 0, status.exitstatus
  assert out =~ /db-1/
  assert out =~ /db-2/
end

test "`tele run -v`" do
  out, err, status = tele("run", "update", "-v", "-d", "test/.tele.simple")

  assert err =~ /Redis succesfully updated/
  assert err =~ /Updating Cassandra failed/
  assert out !~ /Redis succesfully updated/
  assert out !~ /Updating Cassandra failed/
end

test "`tele run -q`" do
  out, err, status = tele("run", "update", "-q", "-d", "test/.tele.simple")

  assert err !~ /Redis succesfully updated/
  assert err !~ /Updating Cassandra failed/
  assert out !~ /Redis succesfully updated/
  assert out !~ /Updating Cassandra failed/
end

__END__

test "`tele init`" do
  `rm -rf test/tmp`
  `mkdir test/tmp`

  assert !File.exists?("test/tmp/.tele")

  Dir.chdir("test/tmp") do
    out, err = tele("init")

    assert File.exists?(".tele")

    out, err, status = tele("status")
    assert status.exitstatus == 0
  end
end
