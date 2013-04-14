require File.dirname(__FILE__) + '/helper'

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
  
  it "should find exact matches for file names" do
    paths = @manifest.scan_for_path('goose')
    paths.size.must_equal 1    
  end
  
  it "should return nothing for inexisting path" do
    paths = @manifest.scan_for_path('shikaka-path/')
    paths.must_equal []
  end
  
  it "should scan for root" do
    paths = @manifest.scan_for_path('/', 'f2b8b135f3a6')
    paths.size.must_equal 17
  end
  
  it "should scan for path with weird characters" do
    paths = @manifest.scan_for_path('check \ this \ out " now', '2d32410d9629')
    paths.size.must_equal 1
  end

  it "should find unicode paths" do
    paths = @manifest.scan_for_path('кодировки/виндоуз-cp1251-lf', 'fe021a290ba1')
    paths.size.must_equal 1
    paths[0].last.must_equal 'кодировки/виндоуз-cp1251-lf'
  end

  if RUBY_VERSION >= '1.9.1'
    it "should return contents in UTF-8 encoding on Ruby 1.9.1 and higher" do
      @manifest.contents.encoding.to_s.downcase.must_equal('utf-8')
    end
  end
  
end
