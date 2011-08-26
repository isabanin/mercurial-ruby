require 'helper'

describe Mercurial::Shell do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
  end
  
  it "should execute hg commands" do
    output = Mercurial::Shell.hg('log', :in => @repository.path)
    (output.size > 100).must_equal true
  end
  
  it "should translate hg errors to ruby exceptions" do
    lambda{ Mercurial::Shell.hg('shikaka', :in => @repository.path) }.must_raise Mercurial::CommandError
  end
  
end