sitecore_config 'Sitecore.Mvc' do
  site 'TestSite'
end

sitecore_config 'Sitecore.Analytics' do
  site 'TestSite'
  action :disable
end

path = ::File.join('C:', 'inetpub', 'wwwroot', 'TestSite', 'Website',
                   'App_Config', 'Include')

sitecore_config 'GlassMapper' do
  configs_path path
end

sitecore_config 'Sitecore.VersionManager' do
  configs_path path
  action :disable
end
