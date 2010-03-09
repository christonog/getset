set :user, 'getsetap'
set :scm, :git
set :branch, :master
set :ip, '68.233.9.46'
set :application, 'getset'
set :applicationdir, 'getset' 
set :repository, "git@getset.sourcerepo.com:getset/getset.git" 
set :use_sudo, false
set :keep_releases, 5

default_run_options[:pty] = true

role :web, ip
role :app, ip
role :db, ip, :primary => true

set :deploy_to, "/home/#{user}/#{applicationdir}" 
set :group_writable, false

