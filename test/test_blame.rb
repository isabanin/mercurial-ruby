require File.dirname(__FILE__) + '/helper'

describe Mercurial::Blame do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @factory = @repository.blames
  end
  
  it "should compile blames into lines" do
    blame = @factory.for_path('LICENSE4.txt')
    lines = blame.lines
    lines.must_be_kind_of Array
    lines.size.must_equal 17
    
    lines[0].must_be_kind_of Mercurial::BlameLine
    lines[0].author.must_equal 'ilya'
    lines[0].revision.must_equal 'bf6386c0a0cc'
    lines[0].num.must_equal 1
    lines[0].contents.must_equal 'Copyright (c) 2008 Josh Nichols'
    
    lines[3].author.must_equal 'ilya'
    lines[3].revision.must_equal '825fd6032c3b'
    lines[3].num.must_equal 4
    lines[3].contents.must_equal ''
  end

  it "should return metadata separately from code" do
    blame = @factory.for_path('diff-test.rb')
    blame.raw_metadata.size.must_equal 26
    blame.raw_metadata[6].must_equal(['ilya', '88b5cc786015', '7'])
  end

  it "should return code separately from metadata" do
    blame = @factory.for_path('diff-test.rb')
    blame.contents_without_metadata.split("\n").size.must_equal 26
    blame.contents_without_metadata.split("\n")[12].must_equal "  helper_method :repository_scope?"
  end
  
end