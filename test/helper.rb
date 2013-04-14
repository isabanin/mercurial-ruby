require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "minitest/autorun"
require "mocha/api"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

$stderr.reopen('/dev/null')

require 'mercurial-ruby'
require 'fixtures'

def erase_fixture_repository
  `rm -Rf #{File.join(File.dirname(__FILE__), 'fixtures', 'test-repo')}`
end

def unpack_fixture_repository
  `unzip #{File.join(File.dirname(__FILE__), 'fixtures', 'test-repo.zip')} -d #{File.join(File.dirname(__FILE__), 'fixtures')}`
end
erase_fixture_repository
unpack_fixture_repository

class MiniTest::Unit::TestCase
  include Mocha::API
  
  def setup
    Mocha::Mockery.instance.stubba.unstub_all
  end
  
private

  def stub_hgrc(path)
    File.open(path, 'w') do |f|
      f << Fixtures.hgrc_sample
    end
  end
  
end

MiniTest::Unit.after_tests { erase_fixture_repository }

MiniTest::Unit.autorun
