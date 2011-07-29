require 'helper'

describe Mercurial::Commit do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @commit = @repository.commits.by_hash_id('34f85a44acf1')
  end
  
  it "should parse date to Ruby format" do
    @commit.date.must_be_kind_of Time
  end
  
  it "should convert changed files list to array" do
    @commit.changed_files.must_be_kind_of Array
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
  
  it "should detect copied files" do
    commit = @repository.commits.by_hash_id('4e9f11e95ead')
    file_one = commit.changed_files.first
    
    file_one[0].must_equal 'LICENSE.txt'
    file_one[1].must_equal :copy
    file_one[2].must_equal 'LICENSE2.txt'
  end
  
  it "should detect modified files" do
    flunk
  end
    
  it "should detect deleted files" do
    flunk
  end
      
  it "should detect moved files" do  
    flunk
  end
  
end