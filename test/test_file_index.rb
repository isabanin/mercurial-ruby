require File.dirname(__FILE__) + '/helper'

describe Mercurial::FileIndex do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @file_index = @repository.file_index
    @file_index.update
  end
  
  after do
    @file_index.destroy!
  end
  
  it "should update index" do
    File.exists?(@file_index.send(:path)).must_equal true
  end
  
  it "should read index even if missing" do
    repository = Mercurial::Repository.create('/tmp/test-repo-bla-bla.hg')
    file_index = repository.file_index
    file_index.count_all.must_equal 0
    repository.destroy!
  end
  
  it "should count all commits" do
    @file_index.count_all.must_equal 44
  end
  
  it "should count commits reachable by specific hash id" do
    @file_index.count('612af4851a6c483f499cadf1dd28040d7996aa78').must_equal 12
  end
  
  it "should return commits that are reachable by specific hash id" do
    commits = @file_index.commits_from('a07263ded0729d146062e6ec076cf1e6af214218')
    commits.must_equal ["a07263ded0729d146062e6ec076cf1e6af214218", "bf6386c0a0ccd1282dbbe51888f52fe82b1806e3"]
  end
  
  it "should return files changed at commit" do
    files = @file_index.files('a8b39838302fc5aad12bb6b043331b9ef50149ed')
    files.size.must_equal 2
    files.sort.must_equal ["new-directory/subdirectory/EULA5seat_Chin_Sim02.03.04.pdf", "new-directory/subdirectory/beansprout.png"].sort
  end
  
  it "should work with files with white-spaces in names" do
    files = @file_index.files('8ddac5f6380ec3094e6c6bb161d7d90e2de16cb0')
    files.size.must_equal 1
    files.sort.must_equal ["File With Whitespace.pdf"].sort
  end
  
  it "should not return files for commit that doesn't exist" do
    files = @file_index.files('f63dvf38302fc5aad12bb6b043331b9ef50149ed')
    files.must_equal []
  end
  
  it "should return commits for a file" do
    commits = @file_index.commits_for('LICENSE3.txt')
    commits.must_equal %w(612af4851a6c483f499cadf1dd28040d7996aa78)
  end
  
  it "should not return commits for file that doesn't exist" do
    commits = @file_index.commits_for('doesntexist')
    commits.must_equal []
  end
  
  it "should return last commits for files" do
    commits = @file_index.last_commits('207476112e024921b1538a096e5f6812d0698cab', ['README.markup'])
    commits.must_equal({ "README.markup" => "54d96f4b1a260dc5614e89c1ed8c2d2edaa4942f" })
    
    commits = @file_index.last_commits('bf6386c0a0ccd1282dbbe51888f52fe82b1806e3', ['README.markup'])
    commits.must_equal({})
    
    commits = @file_index.last_commits('f2b8b135f3a6f254d5ca20e293bffdad03336e57', ['empty-file', 'goose.png'])
    commits.must_equal({ "goose.png"=>"c2b3e46b986e99220e3d2fdb6e44aedbc94b3a85", "empty-file" => "8173f122b0d061e8d398862f1eaf601babf156aa" })
    
    commits = @file_index.last_commits('207476112e024921b1538a096e5f6812d0698cab', ['doesntexist'])
    commits.must_equal({})
  end
  
  it "should return last commits with regex" do
    commits = @file_index.last_commits('1b99d0243f8e5542c1b33a013b63130f9009ac52', /^new-directory\/[^\s\/]+\/?$/)
    commits.size.must_equal 1
    commits.values.first.must_equal '4474d1ddaf653cb7fbf18bb62ff1e39a4e571969'
  end
  
  it "should update existing index by adding a range of commits to it" do
    File.open(@file_index.path, 'w') do |index_file|
      index_file << preset_sample_index
    end
    @file_index.count_all.must_equal 2
    @file_index.update('63f70b2314ede1e12813cae87f6f303ee8d5c09a', 'a8b39838302fc5aad12bb6b043331b9ef50149ed')
    @file_index.reload
    @file_index.count_all.must_equal 26
    @file_index.instance_variable_get('@commit_index').keys.sort.must_equal(['bf6386c0a0ccd1282dbbe51888f52fe82b1806e3', 'bc729b15e2b556065dd4f32c161f54be5dd92776', '63f70b2314ede1e12813cae87f6f303ee8d5c09a', '6157254a442343181939c7af1a744cf2a16afcce', 'a07263ded0729d146062e6ec076cf1e6af214218', '3cdad3d3ca0054ebfcd2652cc83442bd0d272bbb', '25bb5c51fd613b8b58d88ef1caf99da559af51f3', '63e18640e83af60196334f16cc31f4f99c419918', '8fc3d59965d71a9b83308c53a76f3af0235b6eb6', '0f41dd2ec1667518741da599db7264943c9ed472', '16fac694db0a52edfd266576acafb475f7f8420f', '34f85a44acf11c3386f771a65445d6c39e5261d6', '4474d1ddaf653cb7fbf18bb62ff1e39a4e571969', 'cd9fa0c59c7f189fa1d70edea564e534ac9478d0', '611407bf9b369e061eaf0bee1a261c9e62ad713d', 'd14b0c16b21d9d3e08101ef264959a7d91a8b5db', '3e1ea66bdd04dbfb8d91e4f2de3baca218cd4cca', 'bbfe40f4a56961bdfc6b497a19cc35e18f2d40a3', '4e9f11e95eade74c55fc785e3159015f8a472f4b', '11998206a49ca9a55b4065508ce6ca10945e3e73', '1b99d0243f8e5542c1b33a013b63130f9009ac52', '612af4851a6c483f499cadf1dd28040d7996aa78', '54d96f4b1a260dc5614e89c1ed8c2d2edaa4942f', '207476112e024921b1538a096e5f6812d0698cab', 'ea1e37a728e989176e9e7b33f0d0e035fd347623', 'a8b39838302fc5aad12bb6b043331b9ef50149ed'].sort)
  end
  
  it "should raise error if file_index not found" do
    @file_index.stubs(:path).returns('/tmp/blablabla')
    lambda{ @file_index.send(:read_index) }.must_raise Mercurial::FileIndex::IndexFileNotFound
  end
  
  it "should raise error if file_index is too big" do
    Mercurial::FileIndex.stubs(:max_file_size).returns(1)
    lambda{ @file_index.send(:read_index) }.must_raise Mercurial::FileIndex::IndexFileTooBig
  end
  
private

  # contains two oldest commits only
  def preset_sample_index
    %q[bf6386c0a0ccd1282dbbe51888f52fe82b1806e3 0000000000000000000000000000000000000000 0000000000000000000000000000000000000000  Initial files.
LICENSE.txt
README.markdown
Rakefile

bc729b15e2b556065dd4f32c161f54be5dd92776 bf6386c0a0ccd1282dbbe51888f52fe82b1806e3 0000000000000000000000000000000000000000  Directory added
directory_1/rubygems_dot_org_tasks.rb
directory_1/rubygems_tasks.rb
directory_1/specification.rb
directory_1/tasks.rb]
  end
  
end
