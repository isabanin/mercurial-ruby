require 'helper'

describe Mercurial::Shell do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @shell = @repository.shell
  end
  
  it "should compile commands" do    
    command_mock = mock('command', :execute => true)
    Mercurial::Command.expects(:new).with("cd #{ @repository.path } && /usr/local/bin/hg log", :repository => @repository, :cache => true).returns(command_mock).once
    @shell.hg('log')
  end
  
  it "should sanitize command arguments" do
    command_mock = mock('command', :execute => true)
    Mercurial::Command.expects(:new).with(%Q[ls 'file with nasty '\\''quote'], :repository => nil, :cache => true).returns(command_mock).once
    @shell.run(["ls ?", "file with nasty 'quote"])
  end
  
  it "hg method should with string and array commands" do
    @shell.hg('tip')
    @shell.hg(['tip ?', '-g'])
  end
  
end