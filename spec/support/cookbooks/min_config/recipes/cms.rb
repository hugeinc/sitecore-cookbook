sitecore_cms 'TestSite' do
  source ::File.join(Chef::Config[:file_cache_path], 'sitecore.zip')
end
