#
# Cookbook Name:: min_config
# Recipe:: db
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
