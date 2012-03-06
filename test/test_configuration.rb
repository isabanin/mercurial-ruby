require File.dirname(__FILE__) + '/helper'

describe Mercurial::Configuration do
  
  before do 
    @config = Mercurial.configuration
  end
  
  after do 
    Mercurial.configure do |config|
      config.hg_binary_path = '/usr/local/bin/hg'
    end
  end
  
  it "should have default values" do
    @config.hg_binary_path.must_equal '/usr/local/bin/hg'
  end
  
  it "should change values with configure block" do
    Mercurial.configure do |config|
      config.hg_binary_path = '/usr/bin/hg'
    end
    @config.hg_binary_path.must_equal '/usr/bin/hg'    
  end
  
end