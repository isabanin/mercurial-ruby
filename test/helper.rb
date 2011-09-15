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
`unzip #{File.join(File.dirname(__FILE__), 'fixtures', 'test-repo.zip')} -d #{File.join(File.dirname(__FILE__), 'fixtures')}`

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

MiniTest::Unit.after_tests { `rm -Rf #{File.join(File.dirname(__FILE__), 'fixtures', 'test-repo')}` }

MiniTest::Unit.autorun