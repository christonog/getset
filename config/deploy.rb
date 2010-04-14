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

desc "Link in the production database.yml" 
task :after_update_code do
  run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
end

desc "Link Wordpress" 
task :after_update_code do
  run "ln -s #{shared_path}/blog #{release_path}/public" 
end

