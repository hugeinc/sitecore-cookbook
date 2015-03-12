require 'spec_helper'

describe 'sitecore_cms' do
  cached(:cms_run) do
    ChefSpec::SoloRunner.converge('min_config::cms')
  end

  let(:sitecore_zip) do
    ::File.join(Chef::Config[:file_cache_path], 'sitecore_installer', 'Sitecore.zip')
  end

  it 'Installs the CMS from minimum required attributes' do
    expect(cms_run).to install_sitecore_cms('TestSite')
      .with_bindings([{ 'host' => 'TestSite', 'proto' => 'http', 'port' => 80 }])
      .with_path(::File.join('C:', 'inetpub', 'wwwroot', 'TestSite'))
      .with_runtime_version('v4.0')
      .with_identity('NetworkService')
      .with_action(:install)
      .with_hostname('TestSite')
      .with_connection_strings(nil)
      .with_solr_libs(nil)
      .with_source(::File.join(Chef::Config[:file_cache_path], 'sitecore.zip'))
  end

  cached(:advanced_run) do
    ChefSpec::SoloRunner.converge('advanced_config::default')
  end

  let(:bindings) do
    [{
      'host' => 'delivery.example.com',
      'proto' => 'http',
      'port' => 80
    }]
  end

  let(:connection_strings) do
    [
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
    ]
  end

  it 'Installs the CMS from advanced attributes' do
    expect(advanced_run).to install_sitecore_cms('AdvancedSite')
      .with_action([:install])
      .with_source(sitecore_zip)
      .with_bindings(bindings)
      .with_connection_strings(connection_strings)
      .with_license(::File.join(Chef::Config[:file_cache_path], 'my-license.xml'))
  end
end
