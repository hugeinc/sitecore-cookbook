require 'spec_helper'

describe 'sitecore_config' do
  cached(:config_run) do
    ChefSpec::SoloRunner.converge('configure_cms::default')
  end

  let(:configs_path) do
    ::File.join('C:', 'inetpub', 'wwwroot', 'TestSite', 'Website',
                'App_Config', 'Include')
  end

  describe 'given a site name' do
    it 'enables a config file' do
      expect(config_run).to enable_sitecore_config('Sitecore.Mvc')
        .with_action(:enable)
        .with_site('TestSite')
    end

    it 'disables a config file' do
      expect(config_run).to disable_sitecore_config('Sitecore.Analytics')
        .with_action([:disable])
        .with_site('TestSite')
    end
  end

  describe 'given a configs path' do
    it 'enables a config file' do
      expect(config_run).to enable_sitecore_config('GlassMapper')
        .with_action(:enable)
        .with_configs_path(configs_path)
    end

    it 'disables a config file' do
      expect(config_run).to disable_sitecore_config('Sitecore.VersionManager')
        .with_action([:disable])
        .with_configs_path(configs_path)
    end
  end
end
