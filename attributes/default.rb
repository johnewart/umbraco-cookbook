#
# Cookbook Name:: umbraco
# Attributes:: default
#

# Where to find files we need
default['umbraco']['dist'] = 'http://our.umbraco.org/ReleaseDownload?id=92348'

# Where to put the install files
default['umbraco']['site_root'] = "#{ENV['SYSTEMDRIVE']}\\inetpub\\sites\\umbraco"
default['umbraco']['app_root'] = "#{ENV['SYSTEMDRIVE']}\\inetpub\\apps\\umbraco"

# Where to mount the app in IIS and what IIS pool to use
default['umbraco']['app_path'] = '/cms'
default['umbraco']['pool_name'] = 'umbraco'
