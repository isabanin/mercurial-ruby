require File.dirname(__FILE__) + '/helper'

describe Mercurial::Commit do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @commit = @repository.commits.by_hash_id('54d96f4b1a26')
    @files = @commit.changed_files
  end
  
  it "should indicate modified file" do
    file = @files[0]
    file.initial_name.must_equal nil
    file.name.must_equal 'README.markup'
    file.mode.must_equal :edit
  end
  
  it "should indicate added file" do
    file = @files[1]
    file.initial_name.must_equal nil
    file.name.must_equal 'superman.txt'
    file.mode.must_equal :add
  end
  
  it "should indicate deleted file" do
    file = @files[2]
    file.initial_name.must_equal nil
    file.name.must_equal 'Rakefile2'
    file.mode.must_equal :delete
  end
  
  it "should indicate copied file" do
    file = @files[3]
    file.initial_name.must_equal 'LICENSE3.txt'
    file.name.must_equal 'LICENSE4.txt'
    file.mode.must_equal :copy
  end

  it "should indicate moved file" do
    file = @files[4]
    file.initial_name.must_equal 'Rakefile'
    file.name.must_equal 'Rakefile3'
    file.mode.must_equal :move
  end

end