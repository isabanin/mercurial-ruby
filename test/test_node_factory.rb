require 'helper'

describe Mercurial::NodeFactory do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
  end
  
  it "should find any node in the repo" do
    node = @repository.nodes.find('new-directory/', 'a8b39838302f')
    node.must_be_kind_of Mercurial::Node
  end
  
  it "should set revision to tip if not specified" do
    node = @repository.nodes.find('new-directory/')
    node.commit_id.must_equal '291a498f04e9bd0712d92df38aa73dc3a7490f3a'
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
  
end