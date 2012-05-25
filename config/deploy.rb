require 'bundler/capistrano'

set :use_sudo, false
set :user, "hello"


set :application, "hello"
set :repository,  "git@github.com:daichiSato/hello.git"
set :deploy_to ,"/home/#{user}/app/#{application}"

set :scm, :git
set :branch,"master"


set :deploy_via, :copy
set :git_shallow_clone, 1

#default_run_options[:pty] = true


# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

#ssh_options[:keys] = %w(/Users/daichi/.ssh/id_rsa)
#ssh_options[:auth_methods] = %w(publickey)


role :web, "133.242.48.236"                          # Your HTTP server, Apache/etc
role :app, "133.242.48.236"                          # This may be the same as your `Web` server
role :db,  "133.242.48.236", :primary => true # This is where Rails migrations will run


set :default_environment, {
 'PATH' => "~/.rbenv/shims/:~/.rbenv/bin/:$PATH"
 }


# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:


# namespace :deploy do
 #  task :start do 
#	 	run "cd #{current_path} && RAILS_ENV=production bundle exec rails s -d"
#	 end
#   task :stop do 
#	 
#	 	run "killall ruby"
#	 end
 #  task :restart, :roles => :app, :except => { :no_release => true } do
  #   run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  # end
# end
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

namespace :deploy do
    task :start, :roles => :app, :except => { :no_release => true } do 
        run "cd #{current_path} && BUNDLE_GEMFILE=#{current_path}/Gemfile bundle exec unicorn -c #{unicorn_config} -E #{rails_env} -D"
    end
    task :stop, :roles => :app, :except => { :no_release => true } do 
        run "kill `cat #{unicorn_pid}`"
    end
    task :graceful_stop, :roles => :app, :except => { :no_release => true } do
        run "kill -s QUIT `cat #{unicorn_pid}`"
    end
    task :reload, :roles => :app do
        run "kill -s USR2 `cat #{unicorn_pid}`"
    end
    task :restart, :roles => :app, :except => { :no_release => true } do
        stop
        start
    end
end
