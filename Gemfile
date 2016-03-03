source 'https://rubygems.org'

group :development, :test do
  gem 'rake',                    :require => false
  gem 'rspec-puppet', '~> 2.x',  :require => false
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'puppet-lint',             :require => false
end

group :system_tests do
  gem 'beaker', '~>2.2.0',        :require => false
  gem 'beaker-rspec',             :require => false
  gem 'serverspec',               :require => false
  gem 'pry',                      :require => false unless RUBY_VERSION =~ /^1.8/
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
