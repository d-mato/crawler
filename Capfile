require "capistrano/setup"
require "capistrano/deploy"

require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

require 'capistrano/rbenv'
require "capistrano/bundler"
require "capistrano/rails/assets"
require 'capistrano/puma'
install_plugin Capistrano::Puma
require 'capistrano3/ridgepole'
require 'capistrano/sidekiq'

Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
