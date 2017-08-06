#
# Cookbook Name:: sitecore
# HWRP:: db
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

require 'chef/resource'
require_relative '_filesystem_helper'
require_relative '_mssql_helper'

class Chef
  class Resource
    #
    # API for configuring a Sitecore database server.
    #
    class SitecoreDb < Chef::Resource
      identity_attr :host

      def initialize(name, run_context = nil)
        super
        @resource_name = :sitecore_db
        @provider = Chef::Provider::SitecoreDb
        @action = :install
        @allowed_actions = [:install, :create_login, :create_grouplogin, :assign_roles, :assign_db_grouproles]
        @host = name
        @site = ''
        @databases = []
        @username = nil
        @password = nil
        @groupname = nil
        @domainname = nil
        @source_data_directory = ::File.join('C:', 'inetpub', 'wwwroot', site,
                                        'Databases')
        @source_log_directory = ::File.join('C:', 'inetpub', 'wwwroot', site,
                                        'Databases')
        @returns = 0
      end

      #
      # Array of database names to be set up.
      #
      def databases(arg = nil)
        set_or_return(:databases, arg, kind_of: [Array])
      end

      #
      # The database host name.
      #
      def host(arg = nil)
        set_or_return(:host, arg, kind_of: [String])
      end

      #
      # The database user's password.
      #
      def password(arg = nil)
        set_or_return(:password, arg, kind_of: [String])
      end

      #
      # Name of the website.
      #
      def site(arg = nil)
        set_or_return(:site, arg, kind_of: [String])
      end

      #
      # Path to a directory containing the database data files.
      #
      def source_data_directory(arg = nil)
        set_or_return(:source_data_directory, arg, kind_of: [String])
      end

      #
      # Path to a directory containing the database log files.
      #
      def source_log_directory(arg = nil)
        set_or_return(:source_log_directory, arg, kind_of: [String])
      end

      #
      # The database user's name.
      #
      def username(arg = nil)
        set_or_return(:username, arg, kind_of: [String])
      end

      #
      # The database group name.
      #
      def groupname(arg = nil)
        set_or_return(:groupname, arg, kind_of: [String])
      end

      #
      # The database group domain.
      #
      def domainname(arg = nil)
        set_or_return(:domainname, arg, kind_of: [String])
      end

    end
  end
end

class Chef
  class Provider
    #
    # Configures a Sitecore database server.
    #
    class SitecoreDb < Chef::Provider
      include Sitecore::FilesystemHelper
      include Sitecore::MssqlHelper

      DB_TYPES = ['core', 'master', 'web', 'analytics']

      def load_current_resource
        r = new_resource
        @current_resource ||= Resource::SitecoreDb.new(r.host)

        @current_resource.databases(r.databases)
        @current_resource.password(r.password)
        @current_resource.site(r.site)
        @current_resource.source_data_directory(r.source_data_directory)
        @current_resource.source_log_directory(r.source_log_directory)
        @current_resource.username(r.username)
        @current_resource.groupname(r.groupname)
        @current_resource.domainname(r.domainname)

        @current_resource
      end

      def action_install
        r = new_resource
        Chef::Log.info("Setting up databases on #{r.host}")
        r.databases.each do |db|
          data_prefix = ::File.join(r.source_data_directory, db['name'])
          log_prefix = ::File.join(r.source_log_directory, db['name'])
          mdf = "#{data_prefix}.mdf"
          ldf = "#{log_prefix}.ldf"
          unless ::File.exist?(mdf)
            Chef::Log.error("File not found: #{mdf}")
            return
          end
          unless ::File.exist?(ldf)
            Chef::Log.error("File not found: #{ldf}")
            return
          end
          attach_db(r.host, db['name'], mdf, ldf)
        end
      end

      def action_create_login
        r = new_resource
        Chef::Log.info("Creating db login #{r.username}")
        create_login(r.host, r.username, r.password)
        r.databases.each do |db|
          add_login_to_db(r.host, r.username, db['name'])
        end
      end

      def action_create_grouplogin
        r = new_resource
        Chef::Log.info("Creating db login #{r.groupname}")
        create_grouplogin(r.host, r.groupname, r.domainname)
        r.databases.each do |db|
          add_grouplogin_to_db(r.host, r.groupname, db['name'], r.domainname)
        end
      end

      def action_assign_roles
        r = new_resource
        Chef::Log.info("Assigning roles to #{r.username}")
        r.databases.each do |db|
          dbtype = db['type']
          unless DB_TYPES.include?(dbtype)
            Chef::Log.warn("Unknown Sitecore db type: #{dbtype}")
            return nil
          end
          roles = node['sitecore']['roles'][dbtype]
          unless roles.is_a?(Array)
            Chef::Log.warn("No roles found for #{dbtype}")
            return nil
          end
          assign_db_roles(r.host, r.username, db['name'], roles, r.domainname)
        end
      end

      def action_assign_db_grouproles
        r = new_resource
        Chef::Log.info("Assigning roles to #{r.groupname}")
        r.databases.each do |db|
          dbtype = db['type']
          unless DB_TYPES.include?(dbtype)
            Chef::Log.warn("Unknown Sitecore db type: #{dbtype}")
            return nil
          end
          roles = node['sitecore']['roles'][dbtype]
          unless roles.is_a?(Array)
            Chef::Log.warn("No roles found for #{dbtype}")
            return nil
          end
          assign_db_grouproles(r.host, r.groupname, db['name'], roles, r.domainname)
        end
      end
    end
  end
end
