require File.dirname(__FILE__) + '/helper'

describe Mercurial::HookFactory do
  
  before do
    @repository = Mercurial::Repository.create('/tmp/configfile-test.hg')    
    stub_hgrc(@repository.config.path)
  end
  
  after do
    @repository.destroy!
  end
  
  it "should find all hooks" do
    hooks = @repository.hooks.all
    hooks.size.must_equal 2
    hooks.map(&:name).sort.must_equal ['commit', 'changegroup'].sort
    hooks.map(&:value).sort.must_equal ['/Users/ilya/work/beanstalk/script/mercurial/commit.rb', '/Users/ilya/work/beanstalk/script/mercurial/changegroup.rb'].sort
    hooks.first.must_be_kind_of Mercurial::Hook
  end
  
  it "should find hooks by name" do
    hook = @repository.hooks.by_name('changegroup')
    hook.must_be_kind_of Mercurial::Hook
    hook.name.must_equal 'changegroup'
    hook.value.must_equal '/Users/ilya/work/beanstalk/script/mercurial/changegroup.rb'
  end
  
  it "should create hooks" do
    hook = @repository.hooks.add('incoming', 'hg update')
    hook.name.must_equal 'incoming'
    hook.value.must_equal 'hg update'
  end
  
  it "should destroy hooks" do
    Mercurial::Hook.any_instance.expects(:destroy!).once
    @repository.hooks.remove('commit')
  end
  
end