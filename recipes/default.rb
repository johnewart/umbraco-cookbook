#
# Cookbook Name:: umbraco
# Recipe:: default
#

# Install the dependencies for Umbraco - .NET 4.5, IIS web server role, 
::Chef::Recipe.send(:include, Windows::Helper)

windows_feature 'IIS-WebServerRole' do
  action :install
end

# Pre-requisites for ASP.net 4.5
%w{IIS-ISAPIFilter IIS-ISAPIExtensions NetFx3ServerFeatures NetFx4Extended-ASPNET45 IIS-NetFxExtensibility45}.each do |f|
  windows_feature f do
    action :install
  end
end

# Install ASP.net 4.5
windows_feature 'IIS-ASPNET45' do
  action :install
end

# Override the iis cookbook default recipe's W3SVC service to not add it
service "iis" do
  service_name "W3SVC"
  action :nothing
end

# Remove the default IIS site if it's there
include_recipe "iis::remove_default_site"

windows_zipfile node['umbraco']['app_root'] do
  source node['umbraco']['dist']
  action :unzip
  not_if {::File.exists?(::File.join(node['umbraco']['app_root'], "umbraco"))}
end

# Make the required application sub-directories modifiable by the IIS user
%w{App_Data Views css config media masterpages xslt usercontrols bin umbraco scripts images macroscripts}.each do |d|
  directory win_friendly_path(::File.join(node['umbraco']['app_root'], d)) do
    rights [:read,:modify], 'IIS_IUSRS'
  end
end

# Allow IIS user to modify the web.config file for database settings
file win_friendly_path(::File.join(node['umbraco']['app_root'], "web.config")) do
  rights :modify, 'IIS_IUSRS'
end


# Create the IIS application pool using .NET 4.0
iis_pool node['umbraco']['pool_name'] do
  runtime_version "4.0"
  action :add
end

# Create an IIS site from the unzipped app path, rooted at /
iis_site 'umbraco' do
  protocol :http
  port 80
  path node['umbraco']['app_root']
  application_pool node['umbraco']['pool_name']
  action [:add,:start]
end
