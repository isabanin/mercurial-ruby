module Fixtures
  extend self
  
  def test_repo
    File.join(directory, 'test-repo')
  end
  
  def hgrc_sample
    %q[[paths]
default = http://selenic.com/hg

[hooks]
changegroup = /Users/ilya/work/beanstalk/script/mercurial/changegroup.rb
commit =/Users/ilya/work/beanstalk/script/mercurial/commit.rb

[ui]
username = Firstname Lastname <firstname.lastname@example.net>
verbose = True

# [revlog]
# format=0 for revlog; format=1 for revlogng]
  end
  
  def directory
    File.join(File.dirname(__FILE__), 'fixtures')
  end
  
end