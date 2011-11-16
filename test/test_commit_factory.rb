require 'helper'

describe Mercurial::CommitFactory do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
  end

  it "should find commits after specific revision" do
    commits = @repository.commits.after('2d32410d9629')
    commits.size.must_equal 4
    commits.map(&:hash_id).must_equal %w(88b5cc7860153671b0d3aa3c16d01ecad987490e 57a6efe309bfa6c8054084de8c26490fca8a6104 f67625ea8586cd5c4d43c883a273db3ef7f38716 9f76ea916c5100bf61f533c33a6aa9f22532d526)
  end

  it "should find commits before specific revision" do
    commits = @repository.commits.before('63f70b2314ed')
    commits.size.must_equal 2
    commits.map(&:hash_id).must_equal %w(bc729b15e2b556065dd4f32c161f54be5dd92776 bf6386c0a0ccd1282dbbe51888f52fe82b1806e3)
  end

  it "should find commits with limit" do
    commits = @repository.commits.all(:limit => 1)
    commits.size.must_equal 1
  end

  it "should find parent commit" do
    commit = @repository.commits.parent
    commit.must_be_kind_of Mercurial::Commit
  end

  it "should find commit by hash" do
    commit = @repository.commits.by_hash_id('bc729b15e2b5')
    commit.author.must_equal 'Ilya Sabanin'
    commit.author_email.must_equal 'ilya.sabanin@gmail.com'
    commit.hash_id.must_equal 'bc729b15e2b556065dd4f32c161f54be5dd92776'
    commit.message.must_equal 'Directory added'
  end

  it "should not find inexistent commit by hash" do
    lambda { @repository.commits.by_hash_id('dfio9sdf78sdfh') }.must_raise Mercurial::CommandError
  end

  it "should parse commits with big commit messages" do
    commit = @repository.commits.by_hash_id('825fd6032c3b')
    commit.author.must_equal 'Ilya Sabanin'
    commit.author_email.must_equal 'ilya.sabanin@gmail.com'
    commit.hash_id.must_equal '825fd6032c3bbab3677e1890bf05f134a7331533'
    commit.message.must_equal really_long_commit_message
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
    lambda { @repository.commits.by_branch("shikaka") }.must_raise Mercurial::CommandError
  end
  
  it "should find tip commit" do
    tip = @repository.commits.tip
    tip.must_be_kind_of Mercurial::Commit
  end
  
  it "should count commits" do
    count = @repository.commits.count
    count.must_equal 40
  end

  it "should count range of commits" do
    count = @repository.commits.count_range('63f70b2314ed', '3cdad3d3ca00')
    count.must_equal 4
  end

  it "should iterate through commits" do
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

private

  def really_long_commit_message
    %q[check-code: disallow use of hasattr()

The hasattr() builtin from Python < 3.2 [1] has slightly surprising
behavior: it catches all exceptions, even KeyboardInterrupt. This
causes it to have several surprising side effects, such as hiding
warnings that occur during attribute load and causing mysterious
failure modes when ^Cing an application. In later versions of Python
2.x [0], exception classes which do not inherit from Exception (such
as SystemExit and KeyboardInterrupt) are not caught, but other types
of exceptions may still silently cause returning False instead of
getting a reasonable exception.

[0] http://bugs.python.org/issue2196
[1] http://docs.python.org/dev/whatsnew/3.2.html]
  end
  
end
