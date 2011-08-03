require 'helper'

describe Mercurial::Node do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @node = @repository.nodes.find('new-directory/', 'a8b39838302f')
  end
  
  it "should be considered directory when ends with a slash" do
    node = @repository.nodes.find('new-directory/subdirectory/', 'a8b39838302f')
    node.file?.must_equal false
    node.directory?.must_equal true
  end
  
  it "should be considered file when doesn't end with a slash" do
    node = @repository.nodes.find('new-directory/something.csv', 'a8b39838302f')
    node.file?.must_equal true
    node.directory?.must_equal false
  end
  
end