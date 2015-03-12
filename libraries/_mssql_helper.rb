#
# Cookbook Name:: sitecore
# Library: _mssql_helper
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

include Windows::Helper

module Sitecore
  #
  # SQL Server utilities.
  #
  module MssqlHelper
    include Chef::Mixin::PowershellOut

    #
    # Set up a new db by attaching the mdf/ldf combo.
    #
    def attach_db(host, database, mdf_path, ldf_path)
      code = <<EOH
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
$server = New-Object('Microsoft.SqlServer.Management.Smo.Server') '#{host}'
$found = 0
foreach ($db in $server.Databases)
{
  if ($db.Name -eq '#{database}')
  {
    $found = 1
    Break
  }
}

if ($found -eq 0)
{
  $sc = New-Object System.Collections.Specialized.StringCollection
  $sc.Add('#{ps_safe_path(mdf_path)}')
  $sc.Add('#{ps_safe_path(ldf_path)}')
  $server.AttachDatabase('#{database}', $sc)
}
EOH
      powershell_out!(code)
    end

    #
    # Create a new MSSQL login, if one with the given name doesn't already
    # exist.
    #
    def create_login(host, uname, password)
      code = <<EOH
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
$server = New-Object('Microsoft.SqlServer.Management.Smo.Server') #{host}
$name = '#{uname}'
$existingLogin = $server.Logins.Item($name)
if ($existingLogin -eq $NULL)
{
  $login = New-Object Microsoft.SqlServer.Management.Smo.Login('#{host}', $name)
  $login.LoginType = 'SqlLogin'
  $login.PasswordPolicyEnforced = $false
  $login.PasswordExpirationEnabled = $false
  $login.Create('#{password}')
}
EOH
      powershell_out!(code)
    end

    #
    # Add a user to a database, associating it with a pre-existing login of
    # the same name.
    #
    def add_login_to_db(host, username, database)
      code = <<EOH
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
$server = New-Object('Microsoft.SqlServer.Management.Smo.Server') #{host}
$uname = '#{username}'
$db = $server.Databases.Item('#{database}')
$login = $server.Logins.Item($uname)
if ($db -ne $NULL -and $login -ne $NULL)
{
  $user = $db.Users.Item($uname)
  if ($user -eq $NULL)
  {
    $user = New-Object ('Microsoft.SqlServer.Management.Smo.User') ($db, $uname)
    $user.Login = $uname
    $user.Create()
  }
}
EOH
      powershell_out!(code)
    end

    #
    # Assign all the roles named in the given array to the user in the given
    # database.
    #
    def assign_db_roles(host, username, database, roles)
      code = <<EOH
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.Smo')
$server = New-Object('Microsoft.SqlServer.Management.Smo.Server') #{host}
$uname = '#{username}'
$db = $server.Databases.Item('#{database}')
$login = $server.Logins.Item($uname)
$user = $db.Users.Item($uname)
if ($db -ne $NULL -and $login -ne $NULL -and $user -ne $NULL)
{
  $roles = @(#{roles.map { |r| "'#{r}'" }.join(',')})
  foreach ($roleName in $roles)
  {
    if ($user.IsMember($roleName) -eq $false)
    {
      $role = $db.Roles.Item($roleName)
      if ($role -ne $NULL)
      {
        $role.AddMember($uname)
      }
    }
  }
}
EOH
      powershell_out!(code)
    end
  end
end
