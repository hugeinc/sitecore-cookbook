#
# Cookbook Name:: sitecore
# Recipe:: iis
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

include_recipe 'windows'
include_recipe 'iis'

features = %w(
  IIS-WebServerRole IIS-HttpRedirect IIS-LoggingLibraries IIS-RequestMonitor
  IIS-HttpTracing IIS-ISAPIExtensions IIS-IIS6ManagementCompatibility
  IIS-Metabase IIS-ISAPIFilter NetFx3ServerFeatures NetFx3
  NetFx4Extended-ASPNET45 IIS-NetFxExtensibility45 IIS-ASPNET45
  IIS-NetFxExtensibility IIS-HttpRedirect NetFx3ServerFeatures IIS-ASPNET
  IIS-ApplicationDevelopment IIS-ApplicationInit)

features.each do |feature|
  windows_feature feature do
    action :install
  end
end

iis_site 'Default Web Site' do
  action [:stop, :delete]
end
