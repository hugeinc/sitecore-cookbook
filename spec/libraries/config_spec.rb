#
# Cookbook Name:: sitecore
# Spec:: config
#
# Copyright 2014 Huge, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

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
