require 'helper'

describe Mercurial::Manifest do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @manifest = @repository.manifest
  end
  
  it "should have link to repository" do
    @manifest.repository.must_equal @repository
  end
  
  it "should scan for path" do
    paths = @manifest.scan_for_path('new-directory/', 'f2b8b135f3a6')
    paths.map{|p| p[3]}.sort.must_equal %w(new-directory/another-boring-file new-directory/something.csv new-directory/subdirectory/EULA5seat_Chin_Sim02.03.04.pdf new-directory/subdirectory/beansprout.png).sort
  end
  
  it "should return nothing for inexisting path" do
    paths = @manifest.scan_for_path('shikaka-path/')
    paths.must_equal []
  end
  
  it "should scan for root" do
    paths = @manifest.scan_for_path('/', 'f2b8b135f3a6')
    paths.size.must_equal 17
  end
  
end
