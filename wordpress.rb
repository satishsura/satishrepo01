if node['platform'] == 'debian' || node['platform'] == 'ubuntu'
  execute "apt-up" do
    command "apt update"
  end
end

package 'apache2' do
  action :install
end

service "apache2" do
  action :start
end

#package 'mysql-server'
#package 'mysql-client'

#package 'php'
#package 'libapache2-mod-php'
#package 'php-mcrypt'
#package 'php-mysql'
packages = ['mysql-server', 'mysql-client', 'php', 'libapache2-mod-php', 'php-mcrypt', 'php-mysql']

packages.each do |package|
  apt_package package do
    action :install
  end
end

execute "mysqladmin" do
  command 'mysqladmin -u root password rootpassword'
end

remote_file "mysqlcommands" do
  source 'https://gitlab.com/roybhaskar9/devops/raw/master/coding/chef/chefwordpress/files/default/mysqlcommands'
  path "/tmp/mysqlcommands"
end

execute "mysql" do
  command 'mysql -uroot -prootpassword < /tmp/mysqlcommands'
  not_if {File.exists?("/tmp/mysqlcommands")}
end

file "/tmp/mysqlcommands" do
  action :delete
end

remote_file "wordPressLatest" do
  source 'https://wordpress.org/latest.zip'
  path "/tmp/latest.zip"
end

package 'unzip'

execute "unzip" do
  command 'unzip /tmp/latest.zip -d /var/www/html'
  not_if {Dir.exists?("/var/www/html/wordpress")}
end

remote_file "wpconfig" do
  source 'https://gitlab.com/roybhaskar9/devops/raw/master/coding/chef/chefwordpress/files/default/wp-config-sample.php'
  path "/var/www/html/wordpress/wp-config.php"
end

#execute 'chmodword' do
 #command 'chmod -R 775 /var/www/html/wordpress'
#end

#execute 'chownerword' do
 #command 'chown -R www-data:www-data /var/www/html/wordpress'
#end

directory "/var/www/html/wordpress" do
  owner 'www-data'
  group 'www-data'
  mode '0755'
  action :create
  recursive true
end

execute "restart-apache2" do
  command 'service apache2 restart'
end
