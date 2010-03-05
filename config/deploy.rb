set :user, 'getsetap'
set :scm, :git
set :branch, :master
set :server, 'getsetapp.com'
set :application, 'getset'
set :applicationdir, 'getset' 
set :repository, "git@getset.sourcerepo.com:getset/getset.git " 
set :use_sudo, false
set :keep_releases, 5

role :web, server
role :app, server
role :db,  server, :primary => true

set :deploy_to, "/home/#{user}/#{applicationdir}" 
set :group_writable, false