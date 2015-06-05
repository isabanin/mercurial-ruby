require File.dirname(__FILE__) + '/helper'

describe Mercurial::TagFactory do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
  end
  
  it "should find all tags" do
    tags = @repository.tags.all
    tags.size.must_equal 4
    tags.map(&:name).sort.must_equal ['new-tag', 'new-branch-tag', 'tag with space', 'tag.with.dot'].sort
    tags.map(&:hash_id).sort.must_equal %w(63f70b2314ed 9f76ea916c51 bb9cc2a2c920 bf6386c0a0cc).sort
  end
  
  it "should find tag by name" do
    tag = @repository.tags.by_name('new-tag')
    tag.must_be_kind_of(Mercurial::Tag)
    tag.name.must_equal 'new-tag'
    tag.hash_id.must_equal 'bf6386c0a0cc'
  end
  
  it "should not find inexistent tag by name" do
    @repository.tags.by_name('new-tag-shikakabob').must_equal nil
  end
  
end