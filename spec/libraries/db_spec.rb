#
# Cookbook Name:: sitecore
# Spec:: db
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
