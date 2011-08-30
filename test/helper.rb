require 'rubygems'
require 'bundler'
require 'ruby-debug'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require "mocha"
require "minitest/autorun"

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'mercurial-ruby'
require 'fixtures'

$stderr.reopen('/dev/null')

class MiniTest::Unit::TestCase
  
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

MiniTest::Unit.autorun