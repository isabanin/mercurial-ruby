require 'helper'

describe Mercurial::Repository do
  
  describe "creating" do
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
    
    it "should respond to branches" do
      @repository.must_respond_to :branches
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