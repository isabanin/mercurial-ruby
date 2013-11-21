require File.dirname(__FILE__) + '/helper'

describe Mercurial::BranchFactory do

  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
  end

  it "should find all branches" do
    branches = @repository.branches.all
    branches.size.must_equal 6
    branches.map(&:name).sort.must_equal ['another-branch', 'branch-from-remote', 'default', 'my branch', 'new-branch', 'old-branch']
    branches.map(&:status).sort.must_equal %w(active active active active closed inactive)
  end

  it "should iterate through branches" do
    names = []
    @repository.branches.each{|b| names << b.name }
    names.size.must_equal 6
    names.must_equal ['default', 'my branch', 'another-branch', 'branch-from-remote', 'new-branch', 'old-branch']
  end

  it "should find active branches" do
    branches = @repository.branches.active
    branches.size.must_equal 4
    branches.map(&:name).sort.must_equal ['another-branch', 'default', 'branch-from-remote', 'my branch'].sort
    branches.map(&:status).must_equal %w(active active active active)
  end

  it "should find inactive branches" do
    branches = @repository.branches.inactive
    branches.size.must_equal 1
    branches.map(&:name).must_equal %w(new-branch)
    branches.map(&:status).must_equal %w(inactive)
  end

  it "should find closed branches" do
    branches = @repository.branches.closed
    branches.size.must_equal 1
    branches.map(&:name).must_equal %w(old-branch)
    branches.map(&:status).must_equal %w(closed)
  end

  it "should find branch by name" do
    branch = @repository.branches.by_name('default')
    branch.must_be_kind_of(Mercurial::Branch)
    branch.status.must_equal 'active'

    branch = @repository.branches.by_name('new-branch')
    branch.must_be_kind_of(Mercurial::Branch)
    branch.status.must_equal 'inactive'
  end

  it "should not find a branch by inexistent name" do
    @repository.branches.by_name('bla-branch-f').must_equal nil
  end

  it "should return branches for commit" do
    branches = @repository.branches.for_commit('bf6386c0a0cc')
    branches.size.must_equal 6
    branches.map(&:name).sort.must_equal ['old-branch', 'new-branch', 'branch-from-remote', 'another-branch', 'default', 'my branch'].sort
  end

  it "should find branch's full hash_id" do
    branch = @repository.branches.all.first
    branch.hash_id.must_equal '7ac2dcb09643805a97549210e5d0e5511d091c31'
  end

end
