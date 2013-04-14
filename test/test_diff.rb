require File.dirname(__FILE__) + '/helper'

describe Mercurial::Diff do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @commit = @repository.commits.by_hash_id('34f85a44acf1')
    @diff = @commit.diffs.first
  end
  
  it "should have hash_a and hash_b" do
    @diff.hash_a.must_equal '25bb5c51fd61'
    @diff.hash_b.must_equal '34f85a44acf1'
  end
  
  it "should have file_a and file_b" do
    @diff.file_a.must_equal 'Rakefile'
    @diff.file_b.must_equal 'Rakefile'
  end

  it "should have body" do
    @diff.body.strip.must_equal expected_diff.strip
  end

  if RUBY_VERSION >= '1.9.1'
    it "should return file names in UTF-8 encoding in Ruby 1.9.1 and higher" do 
      diff = @repository.diffs.for_path('кодировки/виндоуз-cp1251-lf', 'fe021a290ba1', '2b03a87dbf4c')
      diff.file_a.encoding.to_s.downcase.must_equal 'utf-8'
      diff.file_b.encoding.to_s.downcase.must_equal 'utf-8'
    end
  end
  
private

  def expected_diff
    %q[--- a/Rakefile	Thu Jul 28 00:09:22 2011 +0800
+++ b/Rakefile	Thu Jul 28 02:03:13 2011 +0800
@@ -1,5 +1,7 @@
 # encoding: utf-8
 
+test
+
 require 'rubygems'
 require 'bundler']
  end
  
end
