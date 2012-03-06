require File.dirname(__FILE__) + '/helper'

describe Mercurial::Command do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
  end
  
  it "should execute shell commands" do
    output = Mercurial::Command.new("cd #{ @repository.path } && hg log").execute
    (output.size > 100).must_equal true
  end
  
  it "should translate shell errors to ruby exceptions" do
    lambda{
      Mercurial::Command.new("cd #{ @repository.path } && hg shikaka").execute
    }.must_raise Mercurial::CommandError
  end

  it "should not translate exit status of zero with shell errors to ruby exceptions" do
    Mercurial::Command.new("echo stderr >&2 && echo stdout && exit 0").execute.strip.must_equal "stdout"
  end

  it "should translate exit status of non-zero with shell errors to ruby exceptions" do
    lambda{
      Mercurial::Command.new("echo stderr >&2 && echo stdout && exit 1").execute
    }.must_raise Mercurial::CommandError
  end
  
  it "should execute commands with timeout" do
    Mercurial.configuration.stubs(:shell_timeout).returns(1)
    lambda{
      Mercurial::Command.new("sleep 6").execute
    }.must_raise Timeout::Error
  end
  
  it "should support custom timeout settings" do
    lambda{
      Mercurial::Command.new("sleep 3", :timeout => 1).execute
    }.must_raise Timeout::Error
  end
  
  it "should generate cache key for every command" do
    key = Mercurial::Command.new("cd #{ @repository.path } && hg log", :repository => @repository).send(:cache_key)
    key.must_be_kind_of String
    (key.size > 10).must_equal true
    
    key2 = Mercurial::Command.new("cd #{ @repository.path } && hg log", :repository => @repository).send(:cache_key)
    key.must_equal key2
    
    key3 = Mercurial::Command.new("cd #{ @repository.path } && hg log -v", :repository => @repository).send(:cache_key)
    key3.wont_equal key2
    key3.wont_equal key
  end
  
  it "should cache commands if cache store is available and command is called for repository" do
    command = Mercurial::Command.new("cd #{ @repository.path } && hg log -v", :repository => @repository)
    cache_store = mock('cache_store')
    cache_store.expects(:fetch).with(command.send(:cache_key)).returns(true).once
    Mercurial.configuration.stubs(:cache_store).returns(cache_store)
    command.execute
  end
  
  it "should not use cache store if command is executed outside repository" do
    command = Mercurial::Command.new("ls -l /")
    cache_store = mock('cache_store')
    cache_store.expects(:fetch).never
    command.execute
  end
  
  it "should not use cache store if it's not available" do
    command = Mercurial::Command.new("cd #{ @repository.path } && hg log -v", :repository => @repository)
    cache_store = mock('cache_store')
    cache_store.expects(:fetch).never
    command.execute
  end

  it "should not cache command when caching was specifically disabled" do
    command = Mercurial::Command.new("hg version", :cache => false, :repository => @repository)
    cache_store = mock('cache_store')
    Mercurial.configuration.stubs(:cache_store).returns(cache_store)
    cache_store.expects(:fetch).never
    command.execute
  end
  
  it "should not use caching it it was overridden by repository" do
    command = Mercurial::Command.new("cd #{ @repository.path } && hg log -v", :repository => @repository)
    cache_store = mock('cache_store')
    cache_store.expects(:fetch).never
    Mercurial.configuration.stubs(:cache_store).returns(cache_store)
    @repository.no_cache do
      command.execute
    end
  end
  
end
