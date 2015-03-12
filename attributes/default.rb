#
# Cookbook Name:: sitecore
# Attributes:: default
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

default['sitecore'].tap do |sitecore|
  #
  # The absolute path to Microsoft.Web.Administration.dll on your system.
  #
  sitecore['web_administration_dll'] = ::File.join(
    'c:/', 'windows', 'system32', 'inetsrv',
    'Microsoft.Web.Administration.dll')

  #
  # List of roles which should be assigned to the sitecore SQL user in each
  # database.
  #
  sitecore['roles'] = {
    'core' =>  %w(db_datareader db_datawriter aspnet_Membership_BasicAccess
                  aspnet_Membership_FullAccess aspnet_Membership_ReportingAccess
                  aspnet_Profile_BasicAccess aspnet_Profile_FullAccess
                  aspnet_Profile_ReportingAccess aspnet_Roles_BasicAccess
                  aspnet_Roles_FullAccess aspnet_Roles_ReportingAccess),
    'master' => %w(db_datareader db_datawriter),
    'web' => %w(db_datareader db_datawriter),
    'analytics' =>  %w(db_datareader db_datawriter)
  }
end
