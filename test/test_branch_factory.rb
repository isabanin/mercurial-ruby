require 'helper'

describe Mercurial::BranchFactory do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
  end
  
  it "should find all branches" do
    branches = @repository.branches.all
    branches.size.must_equal 5
    branches.map(&:name).sort.must_equal %w(branch-from-remote another-branch new-branch old-branch default).sort
    branches.map(&:status).sort.must_equal %w(active active closed active active).sort
  end
  
  it "should find active branches" do
    branches = @repository.branches.active
    branches.size.must_equal 4
    branches.map(&:name).sort.must_equal %w(another-branch new-branch default branch-from-remote).sort
    branches.map(&:status).must_equal %w(active active active active)
  end
  
  it "should find closed branches" do
    branches = @repository.branches.closed
    branches.size.must_equal 1
    branches.map(&:name).must_equal %w(old-branch)
    branches.map(&:status).must_equal %w(closed)
  end
  
  it "should find branch by name" do
    branch = @repository.branches.by_name('new-branch')
    branch.must_be_kind_of(Mercurial::Branch)
    branch.status.must_equal 'active'
  end
  
end