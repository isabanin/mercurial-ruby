require File.dirname(__FILE__) + '/helper'

describe Mercurial::ChangedFileFactory do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @commit = @repository.commits.by_hash_id('b66320fa72aa')
    @files = @commit.changed_files
  end
  
  it "should parse files with dot in their names properly" do
    @files.size.must_equal 1
    @files.first.name.must_equal '.DotFile'
  end
  
end