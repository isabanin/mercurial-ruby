require File.dirname(__FILE__) + '/helper'

describe Mercurial::Node do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
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
  
  it "should show node contents" do
    node = @repository.nodes.find('new-directory/something.csv', 'a8b39838302f')
    node.contents.strip.must_equal 'Here will be CSV.'
    
    node = @repository.nodes.find('new-directory/something.csv', '291a498f04e9')
    node.contents.strip.must_equal 'Here will be some new kind of CSV.'
  end
  
  it "should fetch contents of a node with whitespace in it's name" do
    node = @repository.nodes.find('File With Whitespace.pdf', '8ddac5f6380e')
    node.contents.must_equal ''
  end

  if RUBY_VERSION >= '1.9.1'
    it "should return name in UTF-8 encoding on Ruby 1.9.1 and higher" do
      node = @repository.nodes.find('кодировки/виндоуз-cp1251-lf', 'fe021a290ba1')
      node.name.encoding.to_s.downcase.must_equal 'utf-8'
    end
  end
  
end
