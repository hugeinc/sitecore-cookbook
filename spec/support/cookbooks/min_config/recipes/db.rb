sitecore_db '.' do
  action [:install, :create_login, :assign_roles]
  site 'TestSite'
  databases [
    { 'name' => 'Sitecore.Core', 'type' => 'core' },
    { 'name' => 'Sitecore.Master', 'type' => 'master' },
    { 'name' => 'Sitecore.Web', 'type' => 'web' }
  ]
  source_directory ::File.join('C:', 'inetpub', 'wwwroot', 'TestSite', 'Databases')
  username 'sitecore_user'
  password 'foobar123'
end
