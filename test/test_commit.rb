require File.dirname(__FILE__) + '/helper'

describe Mercurial::Commit do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @commit = @repository.commits.by_hash_id('34f85a44acf1')
  end

  it "should have short version of it's id" do
    @commit.short_hash_id.must_equal '34f85a44acf1'
  end
  
  it "should parse date to Ruby format" do 
    @commit.date.must_be_kind_of Time
  end
  
  it "branch name should be 'default' by default" do
    @commit = @repository.commits.by_hash_id('4474d1ddaf65')
    @commit.branch_name.must_equal 'default'
  end
  
  it "should represent tags as Array" do
    @commit.tags_names.must_be_kind_of Array
  end
  
  it "should convert list of changed files to an array of ChangedFile objects" do
    @commit.changed_files.must_be_kind_of Array
    @commit.changed_files.first.must_be_kind_of Mercurial::ChangedFile
  end
  
  it "should have parents_ids array" do
    @commit.parents_ids.must_be_kind_of Array
    @commit.parents_ids.first.must_equal '25bb5c51fd61'
  end
  
  it "should be detected as merge if has many parents" do
    commit = @repository.commits.by_hash_id('cd9fa0c59c7f')
    commit.merge?.must_equal true
    commit.parents_ids.sort.must_equal ["4474d1ddaf65", "6157254a4423"].sort
  end
  
  it "should create commit objects for parents" do
    commit = @repository.commits.by_hash_id('cd9fa0c59c7f')
    commit.parents.each do |parent|
      parent.must_be_kind_of Mercurial::Commit
    end
  end
  
  it "should convert commit to hash" do
    commit = @repository.commits.by_hash_id('cd9fa0c59c7f')
    commit.to_hash.must_be_kind_of Hash
  end
  
  it "should be considered blank if hash is all zeroes" do
    commit = @repository.commits.by_hash_id('cd9fa0c59c7f')
    commit.stubs(:hash_id).returns('0000000000000000000000000000000000000000')
    commit.blank?.must_equal true
  end
  
  it "should return an array of branches where it exists" do
    commit = @repository.commits.by_hash_id('cd9fa0c59c7f')
    commit.exist_in_branches.map(&:name).sort.must_equal %w(default another-branch).sort
  end

  it "should fetch stats" do
    commit = @repository.commits.by_hash_id('cd9fa0c59c7f')
    stats = commit.stats
    stats['files'].must_equal 3
    stats['additions'].must_equal 85
    stats['deletions'].must_equal 6
    stats['total'].must_equal 91
  end

  it "should not die when trying to return stats for a commit without stats" do
    commit = @repository.commits.by_hash_id('8173f122b0d0')
    commit.stats.must_equal Hash.new
  end

  it "should return IDs of it's trivial parents" do
    commit = @repository.commits.by_hash_id('bc729b15e2b5')
    commit.trivial_parents_ids.must_equal %w(bf6386c0a0ccd1282dbbe51888f52fe82b1806e3)
  end

end
