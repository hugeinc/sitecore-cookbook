#
# Cookbook Name:: sitecore
# Library:: _cms_helper
#
# Copyright 2014, Huge, Inc.
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
  # Utilities for doing CMS stuff.
  #
  module CmsHelper
    include Chef::Mixin::PowershellOut
    include Sitecore::FilesystemHelper

    #
    # Set the permissions Sitecore expects on the given directory. If the
    # current ACL matches the new one, do nothing, because setting permissions
    # triggers a CMS restart.
    #
    def set_sitecore_permissions(path, identity = 'NetworkService')
      code = <<EOH
$path = '#{ps_safe_path(path)}'
if (Test-Path $path)
{
  $rights = [System.Security.AccessControl.FileSystemRights]'FullControl,Modify,ReadAndExecute,ListDirectory,Read,Write'
  $inheritanceFlag = @(
    [System.Security.AccessControl.InheritanceFlags]::ContainerInherit,
    [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
  )
  $propFlag = [System.Security.AccessControl.PropagationFlags]'InheritOnly'
  $objType = [System.Security.AccessControl.AccessControlType]::Allow

  $accessCtrlList = Get-Acl $path
  $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    '#{identity}', $rights, $inheritanceFlag, $propFlag, $objType)
  $accessCtrlList.SetAccessRule($accessRule)

  $refObj = ((Get-Acl $path).AccessToString).Split("`n")
  $diffObj = $accessCtrlList.AccessToString.Split("`n")
  $diff = Compare-Object -ReferenceObject $refObj -DifferenceObject $diffObj -IncludeEqual
  foreach ($line in $diff)
  {
    if ($line.SideIndicator -ne '==')
    {
      Set-Acl -Path $path -AclObject $accessCtrlList
      Break
    }
  }
}
EOH
      powershell_out!(code.gsub(/"/, '\\"'))
    end

    #
    # Change an attribute on an element at the given path, in the given file.
    # Don't make any changes if the current and new values match.
    #
    def update_config_node(file_path, xpath, attribute, new_value)
      unless ::File.exist?(file_path)
        Chef::Log.warn("Sitecore config not found: #{file_path}")
        return
      end

      code = <<EOH
$xml = [xml](Get-Content '#{ps_safe_path(file_path)}')
$node = $xml.configuration.SelectSingleNode("#{xpath}")
if ($node -ne $null -and $node.GetAttribute('#{attribute}') -ne '#{new_value}')
{
  $node.SetAttribute('#{attribute}', '#{new_value}')
  $xml.Save('#{ps_safe_path(file_path)}')
}
EOH
      powershell_out!(code.gsub(/"/, '\\"'))
    end

    #
    # Paths like c:/path/to/license.xml are valid for Ruby, but the forward
    # slashes will make Sitecore incorrectly interpret the string as a
    # virtual path.
    #
    def sitecore_safe_path(path)
      path.gsub(::File::SEPARATOR, ::File::ALT_SEPARATOR)
    end

    #
    # Delete any Lucene .config files.
    #
    def remove_lucene_configs(sitecore_web_path)
      path = ::File.join(sitecore_web_path, 'App_Config', 'Include',
                         'Sitecore.ContentSearch.Lucene.*')
      code = "Remove-Item \\\"#{ps_safe_path(path)}\\\""
      powershell_out!(code)
    end
  end
end
