load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy'

after "deploy:update_code", :roles => [:web, :db, :app] do
  run "chown -R #{user}:#{user} /home/#{user}/#{applicationdir}" 
  run "chmod 755 #{current_path}/public -R"
  run "cd #{current_path} && rake db:migrate RAILS_ENV='production'" 
end

after "deploy:update", "deploy:cleanup" 

namespace :deploy do
desc "cold deploy" 
task :cold do
update
passenger::restart
end

desc "Restart Passenger" 
task :restart do
passenger::restart
end
end

namespace :passenger do
desc "Restart Passenger" 
task :restart do
run "cd #{current_path} && touch tmp/restart.txt" 
end
end
