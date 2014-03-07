#
# Recipe build petclinic app from git
#
case node['platform']
  when "ubuntu"
    execute "update packages cache" do
      command "apt-get update"
    end
  end

include_recipe "java"
include_recipe "git"
case node['platform']
  when "ubuntu"
    include_recipe "apt"
    apt_repository "apache-maven3" do
      uri "http://ppa.launchpad.net/natecarlson/maven3/ubuntu/"
      distribution node['lsb']['codename']
      components   ['main']
      keyserver    'keyserver.ubuntu.com'
      key "3DD9F856"
    end
    package "maven3" do
      action :install
    end
    link "/usr/sbin/mvn" do
      to "/usr/bin/mvn3"
    end
  when "centos"
    yum_repository "apache-maven3" do
      description "apache-maven3 repo"
      url "http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-$releasever/$basearch/"
      action :create
    end
    package "apache-maven" do
      action :install
    end
    link "/usr/sbin/mvn" do
      to "/usr/share/apache-maven/bin/mvn"
    end
  end

git_url="/tmp/gittest"
new_git_url = "#{node['scm']['repository']}?#{node['scm']['revision']}"
cur_git_url = ""

if File.exist?(git_url)
  cur_git_url = File.read(git_url)
end

if !cur_git_url.eql? new_git_url

  case node['scm']['provider']
    when "git"
      bash " clean #{node['build']['dest_path']}/webapp" do
        code <<-EEND
          rm -rf #{node['build']['dest_path']}/webapp
        EEND
      end
      git "#{node['build']['dest_path']}/webapp" do
        repository node['scm']['repository']
        revision node['scm']['revision']
        action :sync
      end
    when "subversion"
      Chef::Provider::Subversion
    when "remotefile"
      Chef::Provider::RemoteFile::Deploy
    when "file"
      Chef::Provider::File::Deploy
  end

  execute "package" do
    command "cd #{node['build']['dest_path']}/webapp; mvn clean package && cp #{node['build']['dest_path']}/webapp/target/*.war #{node['build']['dest_path']}/#{node['build']['dest_name']}.war"
  end

  node.set['build']['package']="#{node['build']['dest_path']}/#{node['build']['dest_name']}.war"

  File.open(git_url, 'w') { |file| file.write("#{node['scm']['repository']}?#{node['scm']['revision']}") }
end
