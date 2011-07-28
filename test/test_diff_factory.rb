require 'helper'

describe Mercurial::DiffFactory do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
  end
  
  it "should find diffs for commit" do
    commit = @repository.commits.by_hash_id('bbfe40f4a569')
    diffs = @repository.diffs.for_commit(commit)
    diffs.map(&:hash_a).uniq.must_equal %w(d14b0c16b21d)
    diffs.map(&:hash_b).uniq.must_equal %w(bbfe40f4a569)
  end
  
end