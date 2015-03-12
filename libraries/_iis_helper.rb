#
# Cookbook Name:: sitecore
# Library:: _iis_helper
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

require_relative '_filesystem_helper'

include Windows::Helper

module Sitecore
  #
  # Utilities for working with IIS.
  #
  module IISHelper
    include Chef::Mixin::PowershellOut
    include Sitecore::FilesystemHelper

    #
    # Create an IIS Application Pool from the given parameters, if a matching
    # pool doesn't already exist.
    #
    def create_app_pool(name, runtime, identity)
      web_administration = node['sitecore']['web_administration_dll']
      code = <<EOH
[System.Reflection.Assembly]::LoadFrom('#{web_administration}') | Out-Null
Import-Module WebAdministration;
$siteName = '#{name}';
$server = New-Object Microsoft.Web.Administration.ServerManager;
if ($server.ApplicationPools[$siteName] -eq $NULL)
{
  $appPool = $server.ApplicationPools.Add($siteName);
  $appPool.ManagedRuntimeVersion = '#{runtime}';
  $appPool.ProcessModel.IdentityType = '#{identity}';
  $appPool.ProcessModel.IdleTimeout = [TimeSpan] '0.00:00:00';
  $appPool.Recycling.PeriodicRestart.time = [TimeSpan] '00:00:00';
  $server.CommitChanges();
  Start-Sleep -milliseconds 1000
}
EOH
      powershell_out!(code)
    end

    #
    # Create an IIS Website from the given parameters, if a matching
    # site doesn't already exist.
    #
    def create_iis_website(name, path, primary_binding)
      web_administration = node['sitecore']['web_administration_dll']
      code = <<EOH
[System.Reflection.Assembly]::LoadFrom('#{web_administration}') | Out-Null
Import-Module WebAdministration
$siteName = '#{name}'
$server = New-Object Microsoft.Web.Administration.ServerManager
if ($server.Sites[$siteName] -eq $NULL)
{
  $binding = ':#{primary_binding['port']}:#{primary_binding['host']}'
  $path = '#{ps_safe_path(path)}'
  $proto = '#{primary_binding['proto']}'
  $site = $server.Sites.Add($siteName, $proto, $binding, $path)
  $site.Applications[0].ApplicationPoolName = $siteName
  Start-Sleep -milliseconds 1000
  $server.CommitChanges()
  Start-Sleep -milliseconds 1000
}
EOH
      powershell_out!(code)
    end

    def add_bindings(site_name, bindings)
      str = bindings.map do |b|
        sprintf('@{"Protocol"="%s";"BindingInformation"=":%d:%s"}',
                b['proto'], b['port'], b['host'])
      end.join(',')

      web_administration = node['sitecore']['web_administration_dll']
      code = <<EOH
[System.Reflection.Assembly]::LoadFrom('#{web_administration}') | Out-Null
Import-Module WebAdministration
$site = Get-Item IIS:/Sites/'#{site_name}'
if ($site -ne $NULL)
{
  $bindings = @(#{str})
  foreach ($b in $bindings)
  {
    if (!([bool]($site.Bindings.Collection | `
      ? { $_.bindingInformation -eq $b['BindingInformation'] })))
    {
      New-ItemProperty IIS:/Sites/'#{site_name}' `
        -name bindings -value `
        @{Protocol=$b['Protocol'];BindingInformation=$b['BindingInformation']}
    }
  }
}
EOH
      powershell_out!(code.gsub(/"/, '\\"'))
    end
  end
end
