require 'helper'

describe Mercurial::DiffFactory do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
  end
  
  it "should find diffs for commit" do
    commit = @repository.commits.by_hash_id('54d96f4b1a26')
    diffs = @repository.diffs.for_commit(commit)
    diffs.size.must_equal 6
    diffs.map(&:file_name).sort.must_equal ['LICENSE4.txt', 'README.markup', 'Rakefile', 'Rakefile2', 'Rakefile3', 'superman.txt']
  end
  
  it "should work for files with dots in their names" do
    commit = @repository.commits.by_hash_id('b66320fa72aa')
    diffs = commit.diffs
    diffs.size.must_equal 1
    diffs.first.file_name.must_equal '.DotFile'
  end
  
  it "should handle binary files properly" do
    commit = @repository.commits.by_hash_id('c2b3e46b986e')
    commit.diffs.size.must_equal 1
    diff = commit.diffs.first
    diff.must_be_kind_of Mercurial::Diff
    diff.file_name.must_equal 'goose.png'
    diff.body.must_equal 'Binary files differ'
    diff.binary?.must_equal true
  end
  
end