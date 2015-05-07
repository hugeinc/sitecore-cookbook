#
# Cookbook Name:: advanced_config
# Recipe:: default
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
    },
    {
      'name' => 'analytics',
      'connection_string' => 'mongodb://mongodb/analytics'
    }
  ])
  license license_path
end
