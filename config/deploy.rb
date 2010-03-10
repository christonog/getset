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
set :shared_dir, "#{deploy_to}/shared"
set :release_path, "/#{deploy_to}/current"
set :group_writable, false

desc "Link in the production database.yml" 
task :after_update_code do
  run "ln -nfs #{release_path}/config/database.yml #{deploy_to}/#{shared_dir}/config/database.yml" 
end


