require 'helper'

describe Mercurial::CommitFactory do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
  end
  
  it "should find commit by hash" do
    commit = @repository.commits.by_hash_id('bc729b15e2b5')
    commit.author.must_equal 'Ilya Sabanin'
    commit.author_email.must_equal 'ilya.sabanin@gmail.com'
    commit.hash_id.must_equal 'bc729b15e2b556065dd4f32c161f54be5dd92776'
    commit.message.must_equal 'Directory added'
  end
  
  it "should not find inexistent commit by hash" do
    @repository.commits.by_hash_id('dfio9sdf78sdfh').must_equal nil
  end
  
  it "should find arrays of commits by their hashes" do
    commits = @repository.commits.by_hash_ids(['6157254a4423', 'bf6386c0a0cc'])
    commits.map(&:hash_id).sort.must_equal %w(6157254a442343181939c7af1a744cf2a16afcce bf6386c0a0ccd1282dbbe51888f52fe82b1806e3).sort
    commits.map(&:author_email).uniq.must_equal %w(ilya.sabanin@gmail.com)
  end
  
  it "should find many commits with multiple arguments instead of array" do
    commits = @repository.commits.by_hash_ids('6157254a4423', 'bf6386c0a0cc')
    commits.map(&:hash_id).sort.must_equal %w(6157254a442343181939c7af1a744cf2a16afcce bf6386c0a0ccd1282dbbe51888f52fe82b1806e3).sort
    commits.map(&:author_email).uniq.must_equal %w(ilya.sabanin@gmail.com)
  end
  
  it "should find all commits" do
    commits = @repository.commits.all
    (commits.size > 5).must_equal true
  end
  
  it "should find commits by branch" do
    commits = @repository.commits.by_branch("new-branch")
    commits.size.must_equal 3
    commits.map(&:hash_id).sort.must_equal ["63e18640e83af60196334f16cc31f4f99c419918", "63f70b2314ede1e12813cae87f6f303ee8d5c09a", "bc729b15e2b556065dd4f32c161f54be5dd92776"].sort
  end
  
  it "should not find commits for inexistent branch" do
    @repository.commits.by_branch("shikaka").must_equal []
  end
  
  it "should find tip commit" do
    tip = @repository.commits.tip
    tip.must_be_kind_of Mercurial::Commit
  end
  
  it "should count commits" do
    count = @repository.commits.count
    count.must_equal 32
  end
  
  it "should iterate commits" do
    @repository.commits.each do |c|
      c.must_be_kind_of Mercurial::Commit
    end
  end
  
  it "should find commits for range" do
    commits = @repository.commits.for_range('bc729b15e2b5', 'a07263ded072')
    commits.map(&:hash_id).sort.must_equal ['bc729b15e2b556065dd4f32c161f54be5dd92776', '63f70b2314ede1e12813cae87f6f303ee8d5c09a', '6157254a442343181939c7af1a744cf2a16afcce', 'a07263ded0729d146062e6ec076cf1e6af214218'].sort
  end
  
  it "should return nil instead of latest commit if it's blank" do
    FileUtils.rm_rf('/tmp/new-crazy-repo')
    Mercurial::Repository.create('/tmp/new-crazy-repo').commits.latest.must_equal nil
  end
  
end