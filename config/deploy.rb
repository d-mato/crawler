set :application, 'crawler'
set :repo_url, 'git@github.com:d-mato/crawler.git'
set :deploy_to, '/home/ec2-user/crawler'

append :linked_files, 'config/master.key'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'storage', 'public/system'

after 'deploy:publishing', 'ridgepole:apply'
