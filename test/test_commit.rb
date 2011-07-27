require 'helper'

describe Mercurial::Commit do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @commit = @repository.commits.by_hash_id('34f85a44acf1')
  end
  
  it "should load diff" do
    @commit.diff.must_equal expected_diff
  end  
  
private

  def expected_diff
    %Q[diff -r 25bb5c51fd61 -r 34f85a44acf1 Rakefile
--- a/Rakefile	Thu Jul 28 00:09:22 2011 +0800
+++ b/Rakefile	Thu Jul 28 02:03:13 2011 +0800
@@ -1,5 +1,7 @@
 # encoding: utf-8
 
+test
+
 require 'rubygems'
 require 'bundler'
 
]
  end

end