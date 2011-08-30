require 'helper'

describe Mercurial::Shell do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @shell = @repository.shell
  end
  
  it "should compile commands" do    
    command_mock = MiniTest::Mock.new
    command_mock.expect(:execute, true)
    Mercurial::Command.expects(:new).with("cd #{ @repository.path } && /usr/local/bin/hg log").returns(command_mock).once
    @shell.hg('log')
  end
  
end