require 'helper'

describe Mercurial::ConfigFile do
  
  before do
    @repository = Mercurial::Repository.create('/tmp/configfile-test.hg')    
    @config = @repository.config
    stub_hgrc(@config.path)
  end
  
  after do
    @repository.destroy!
  end
  
  it "should state as existing" do
    @config.exists?.must_equal true
  end
  
  it "should have content" do
    @config.contents.size.must_equal 324
  end
  
  it "should add settings" do
    @config.add_setting('hooks', 'incoming', 'hg update')
    @config.contents.must_equal hgrc_with_incoming_hook_added
    @config.find_header('hooks').size.must_equal 3
    @config.find_setting('hooks', 'incoming').must_equal "incoming = hg update\n"
    @config.find_setting('hooks', 'commit').must_equal "commit =/Users/ilya/work/beanstalk/script/mercurial/commit.rb\n\n"
    @config.find_setting('hooks', 'sfdf').must_equal nil
  end
  
  it "should delete settings" do
    @config.delete_setting!('hooks', 'commit')
    @config.contents.must_equal hgrc_with_commit_hook_deleted
    @config.find_header('hooks').size.must_equal 1
    @config.find_setting('hooks', 'commit').must_equal nil
    @config.find_setting('hooks', 'changegroup').must_equal "changegroup = /Users/ilya/work/beanstalk/script/mercurial/changegroup.rb\n"
  end
  
private

  def hgrc_with_incoming_hook_added
    %q[[paths]
default = http://selenic.com/hg

[hooks]
incoming = hg update
changegroup = /Users/ilya/work/beanstalk/script/mercurial/changegroup.rb
commit =/Users/ilya/work/beanstalk/script/mercurial/commit.rb

[ui]
username = Firstname Lastname <firstname.lastname@example.net>
verbose = True

# [revlog]
# format=0 for revlog; format=1 for revlogng]
  end
  
  def hgrc_with_commit_hook_deleted
    %q[[paths]
default = http://selenic.com/hg

[hooks]
changegroup = /Users/ilya/work/beanstalk/script/mercurial/changegroup.rb
[ui]
username = Firstname Lastname <firstname.lastname@example.net>
verbose = True

# [revlog]
# format=0 for revlog; format=1 for revlogng]
  end

end