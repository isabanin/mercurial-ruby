require 'helper'

describe Mercurial::Repository do
  
  it "should raise an error when trying to open a repository that doesn't exist on disk" do
    lambda{ Mercurial::Repository.open('/shikaka/bambucha') }.must_raise Mercurial::RepositoryNotFound
  end
  
  describe "when created" do
    before do
      @repository = Mercurial::Repository.create('/tmp/test-hg-repo')
    end
    
    after do
      @repository.destroy!
    end
    
    it "should have valid path" do
      @repository.path.must_equal '/tmp/test-hg-repo'
    end
    
    it "should create a Mercurial repo on disk" do
      File.exists?(File.join(@repository.path, '.hg')).must_equal true
    end
    
    it "should respond to hooks" do
      @repository.must_respond_to :hooks
    end
    
    it "should respond to commits" do
      @repository.must_respond_to :commits
    end
    
    it "should respond to branches" do
      @repository.must_respond_to :branches
    end
    
    it "should respond to tags" do
      @repository.must_respond_to :tags
    end
    
    it "should respond to diffs" do
      @repository.must_respond_to :diffs
    end
    
    it "should have file system url" do
      @repository.file_system_url.must_equal "file:///tmp/test-hg-repo"
    end
    
    it "should clone" do
      result = @repository.clone('/tmp/test-hg-repo-clone')
      assert_equal '/tmp/test-hg-repo-clone', result
      assert FileTest.directory?('/tmp/test-hg-repo-clone/.hg')
      FileUtils.rm_rf('/tmp/test-hg-repo-clone')
    end
  end
  
  describe "destroying" do
    before do
      @repository = Mercurial::Repository.create('/tmp/test-hg-repo')
      @repository.destroy!
    end
    
    it "should remove Mercurial repo from disk" do      
      File.exists?(@repository.path).must_equal false
    end
  end

end