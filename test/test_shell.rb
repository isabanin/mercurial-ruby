require File.dirname(__FILE__) + '/helper'

describe Mercurial::Shell do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @shell = @repository.shell
  end

  it "should accept piping" do
    assert_equal '1', @shell.hg('log', :pipe => "grep '9:0f41dd2ec166' -wc").strip
  end
  
  it "should compile commands" do    
    command_mock = mock('command', :execute => true)
    Mercurial::Command.expects(:new).with("cd '#{ @repository.path }' && /usr/local/bin/hg log", :repository => @repository, :append_hg => true).returns(command_mock).once
    @shell.hg('log')
  end
  
  it "should sanitize command arguments" do
    command_mock = mock('command', :execute => true)
    Mercurial::Command.expects(:new).with(%Q[ls 'file with nasty '\\''quote'], {}).returns(command_mock).once
    @shell.run(["ls ?", "file with nasty 'quote"])
  end
  
  it "should work with string and array commands" do
    @shell.hg('tip')
    @shell.hg(['tip ?', '-g'])
  end
  
  it "should execute commands without cache" do
    command_mock = mock('command', :execute => true)
    Mercurial::Command.expects(:new).with('ls -l /', :cache => false).returns(command_mock).once
    Mercurial::Shell.run('ls -l /', :cache => false)
  end
  
end
