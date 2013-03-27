require File.dirname(__FILE__) + '/helper'

describe Mercurial::NodeFactory do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
  end
  
  it "should raise exception when find used with exclamation point and node missing" do
    lambda { @repository.nodes.find!('jahdfer') }.must_raise Mercurial::NodeMissing
  end
  
  it "should return nil for file that doesn't exist" do
    node = @repository.nodes.find('shikakablala4', 'a8b39838302f')
    node.must_equal nil
  end
  
  it "should find a directory in the repo" do
    node = @repository.nodes.find('new-directory/', 'a8b39838302f')
    node.name.must_equal 'new-directory/'
    node.path.must_equal 'new-directory/'
    node.directory?.must_equal true
    node.fmode.must_equal nil
    node.executable.must_equal false
    node.revision.must_equal 'a8b39838302f'
    node.nodeid.must_equal nil
    node.must_be_kind_of Mercurial::Node
  end
  
  it "should find a directory even if I specified it without trailing slash" do
    node = @repository.nodes.find('new-directory/subdirectory', 'a8b39838302f')
    node.name.must_equal 'subdirectory/'
    node.directory?.must_equal true
  end
  
  it "should find file" do
    node = @repository.nodes.find('new-directory/something.csv', 'a8b39838302f')
    node.name.must_equal 'something.csv'
    node.path.must_equal 'new-directory/something.csv'
    node.directory?.must_equal false
    node.file?.must_equal true
    node.fmode.must_equal '644'
    node.executable.must_equal false
    node.revision.must_equal 'a8b39838302f'
    node.nodeid.must_equal '74dea67fb438acdb2cc103b3d289d4a8856718cc'
    node.must_be_kind_of Mercurial::Node
  end
  
  it "should find deleted file" do
    node = @repository.nodes.find('old-directory/options.rb', 'a07263ded072')
    node.name.must_equal 'options.rb'
    node.path.must_equal 'old-directory/options.rb'
    node.directory?.must_equal false
    node.file?.must_equal true
    node.fmode.must_equal '644'
    node.executable.must_equal false
    node.revision.must_equal 'a07263ded072'
    node.nodeid.must_equal '75fe47582b041b66d5ab1606cf3cff140038d7bd'
    node.must_be_kind_of Mercurial::Node
  end

  it "should find entries for node" do
    node = @repository.nodes.find('new-directory/', 'a8b39838302f')
    entries = node.entries
    entries.size.must_equal 3
    entries.each {|e| e.must_be_kind_of Mercurial::Node }
    entries.map(&:name).sort.must_equal %w(another-boring-file something.csv subdirectory/).sort
    entries.map(&:parent).uniq.must_equal [node]
    
    entries[0].file?.must_equal true
    entries[0].directory?.must_equal false

    entries[1].file?.must_equal true
    entries[1].directory?.must_equal false

    entries[2].directory?.must_equal true
    entries[2].file?.must_equal false
  end
  
  it "should find entries for tip revision" do
    node = @repository.nodes.find('new-directory/subdirectory')
    entries = node.entries
    entries.size.must_equal 3
    entries.map{|e| e.file?}.must_equal [true, true, true]
  end
  
  it "should find entries for node without trailing slash" do
    node = @repository.nodes.find('new-directory', 'a8b39838302f')
    entries = node.entries
    entries.size.must_equal 3
    entries.map(&:name).sort.must_equal %w(another-boring-file something.csv subdirectory/).sort
  end
 
  it "should find root node" do
    node = @repository.nodes.find('/')
    node.must_be_kind_of Mercurial::RootNode
  end
  
  it "should find entries for root node" do
    node = @repository.nodes.find('/', 'f2b8b135f3a6')
    node.must_be_kind_of Mercurial::RootNode
    entries = node.entries
    entries.size.must_equal 14
    entries.map(&:name).sort.must_equal %w(.DotFile .hgignore .hgtags LICENSE3.txt LICENSE4.txt README.markup Rakefile3 empty-file goose.png new-directory/ riot_mixin.rb style superman.txt testspec_mixin_new.rb).sort
  end
  
  it "should work fine with files with whitespace in their name" do
    node = @repository.nodes.find('File With Whitespace.pdf', '8ddac5f6380e')
    node.name.must_equal 'File With Whitespace.pdf'
    
    root = @repository.nodes.find('/', '8ddac5f6380e')
    node2 = root.entries.find{|f| f.name == 'File With Whitespace.pdf'}
    node2.must_be_kind_of Mercurial::Node
    
    node3 = @repository.nodes.find('new-directory/subdirectory/File With Whitespace.pdf', 'bb9cc2a2c920')
    node3.name.must_equal 'File With Whitespace.pdf'
  end
  
  it "should find file with weird characters in it's name" do
    node = @repository.nodes.find('check \ this \ out " now', '2d32410d9629')
    node.name.must_equal 'check \ this \ out " now'
    node.file?.must_equal true
  end

end