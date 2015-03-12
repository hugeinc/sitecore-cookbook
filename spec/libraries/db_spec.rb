require 'spec_helper'

describe 'sitecore_db' do
  cached(:db_run) do
    ChefSpec::SoloRunner.converge('min_config::db')
  end

  it 'Installs the Sitecore databases and creates the given user' do
    expect(db_run).to install_sitecore_db('.')
      .with_action([:install, :create_login, :assign_roles])
      .with_site('TestSite')
      .with_databases([
          { 'name' => 'Sitecore.Core', 'type' => 'core' },
          { 'name' => 'Sitecore.Master', 'type' => 'master' },
          { 'name' => 'Sitecore.Web', 'type' => 'web' }
        ])
      .with_source_directory(::File.join('C:', 'inetpub', 'wwwroot',
                                         'TestSite', 'Databases'))
      .with_username('sitecore_user')
      .with_password('foobar123')
  end
end
