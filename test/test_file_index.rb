require 'helper'

describe Mercurial::FileIndex do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @file_index = @repository.file_index
  end
  
  it "should update index" do
    @file_index.destroy!
    @file_index.update
    File.exists?(@file_index.send(:index_file_path)).must_equal true
  end
  
  it "should count all commits" do
    @file_index.count_all.must_equal 31
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
  
end