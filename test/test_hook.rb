require File.dirname(__FILE__) + '/helper'

describe Mercurial::Hook do
  
  before do
    @repository = Mercurial::Repository.create('/tmp/test-hg-repo')
    stub_hgrc(@repository.config.path)
    @hook = @repository.hooks.by_name('changegroup')    
  end
  
  after do
    @repository.destroy!
  end
  
  it "should have name" do
    @hook.name.must_equal 'changegroup'
  end
  
  it "should have value" do
    @hook.value.must_equal '/Users/ilya/work/beanstalk/script/mercurial/changegroup.rb'
  end
  
  it "should have repository" do
    @hook.repository.must_equal @repository
  end
  
  it "should add itself to the config" do
    hook = Mercurial::Hook.new(@repository, 'outcoming', 'hg update')
    hook.save
    @repository.hooks.by_name('outcoming').value.must_equal 'hg update'
  end
  
  it "should remove itself from the config" do
    @hook.destroy!
    @repository.hooks.by_name('changegroup').must_equal nil
    @repository.hooks.by_name('commit').value.must_equal '/Users/ilya/work/beanstalk/script/mercurial/commit.rb'
  end

end
