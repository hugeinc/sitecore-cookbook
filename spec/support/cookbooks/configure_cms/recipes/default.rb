#
# Cookbook Name:: configure_cms
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
