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

desc 'Symlink shared configs and folders on each release.'
task :symlink_shared do
  out =  [ 'public/system', 'config/database.yml', 'config/mongrel_cluster.yml', 'vendor/rails' ].collect do |name|
           "ln -s #{shared_path}/#{name} #{release_path}/#{name}"
         end.join(' && ')
  run out
end

after 'deploy:update_code', 'symlink_shared'

=begin
desc "Link in the production database.yml" 
task :after_update_code, :roles => [:web, :db, :app] do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
end
=end

desc "Link Wordpress" 
task :after_update_code do
  run "ln -s #{shared_path}/blog #{release_path}/public" 
end

