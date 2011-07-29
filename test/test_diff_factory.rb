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
  
end