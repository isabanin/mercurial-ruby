require 'helper'

describe Mercurial::NodeFactory do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
  end
  
  it "should find any node in the repo" do
    node = @repository.nodes.find('new-directory/', 'a8b39838302f')
    node.name.must_equal 'new-directory/'
    node.directory?.must_equal true
    node.must_be_kind_of Mercurial::Node
  end
  
  it "should find a directory even if I specified it without trailing slash" do
    node = @repository.nodes.find('new-directory/subdirectory', 'a8b39838302f')
    node.name.must_equal 'subdirectory'
    node.directory?.must_equal true
    node.must_be_kind_of Mercurial::Node
  end
  
  it "should find entries for node" do
    node = @repository.nodes.find('new-directory/', 'a8b39838302f')
    entries = node.entries
    entries.size.must_equal 3
    entries.each {|e| e.must_be_kind_of Mercurial::Node }
    entries.map(&:name).sort.must_equal %w(another-boring-file something.csv subdirectory/).sort
    entries[0].directory?.must_equal true
    entries[0].file?.must_equal false
    
    entries[1].file?.must_equal true
    entries[1].directory?.must_equal false

    entries[2].file?.must_equal true
    entries[2].directory?.must_equal false
  end
  
  it "should find entries for root" do
    node = @repository.nodes.find('/')
    entries = node.entries
    entries.size.must_equal 17
  end
  
end