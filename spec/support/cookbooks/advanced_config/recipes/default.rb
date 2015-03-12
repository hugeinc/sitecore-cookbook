assets_path = ::File.join(Chef::Config[:file_cache_path], 'sitecore_installer')
license_path = ::File.join(Chef::Config[:file_cache_path], 'my-license.xml')

sitecore_cms 'AdvancedSite' do
  action [:install]
  source ::File.join(assets_path, 'Sitecore.zip')
  bindings([{
    'host' => 'delivery.example.com',
    'proto' => 'http',
    'port' => 80
  }])
  connection_strings([
    {
      'name' => 'core',
      'user_id' => 'sitecore_user',
      'password' => 'a_password',
      'data_source' => 'db.delivery1.example.com',
      'database' => 'sitecore_core'
    },
    {
      'name' => 'web',
      'user_id' => 'sitecore_user',
      'password' => 'a_password',
      'data_source' => 'db.delivery1.example.com',
      'database' => 'sitecore_web'
    }
  ])
  license license_path
end
