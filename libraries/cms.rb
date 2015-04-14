#
# Cookbook Name:: sitecore
# HWRP:: cms
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

require 'fileutils'
require 'chef/resource'
require_relative '_cms_helper'
require_relative '_filesystem_helper'
require_relative '_iis_helper'

class Chef
  class Resource
    #
    # API for customizing a Sitecore CMS installation.
    #
    class SitecoreCms < Chef::Resource
      identity_attr :name

      def initialize(name, run_context = nil)
        super
        @resource_name = :sitecore_cms
        @provider = Chef::Provider::SitecoreCms
        @action = :install
        @allowed_actions = [:install, :enable_solr]
        @name = name
        @bindings = [{ 'host' => name, 'proto' => 'http', 'port' => 80 }]
        @connection_strings = nil
        @hostname = name
        @path = ::File.join('C:', 'inetpub', 'wwwroot', name)
        @runtime_version = 'v4.0'
        @identity = 'NetworkService'
        @solr_libs = nil
        @returns = 0
      end

      #
      # Bindings for accessing the site. Format:
      # [ { 'host' => 'example.com', 'port' => 80, 'proto' => 'http' } ]
      #
      def bindings(arg = nil)
        set_or_return(:bindings, arg, kind_of: [Array])
      end

      #
      # Checksum for validating the Sitecore zip.
      #
      def checksum(arg = nil)
        set_or_return(:checksum, arg, kind_of: [String])
      end

      #
      # Database connection parameters, in this format:
      # [{
      #   'name' => 'core',
      #   'user_id' => 'sitecore_user',
      #   'password' => 'their_password',
      #   'data_source' => 'dbserver.example.com',
      #   'database' => 'sitecore_core'
      # }]
      #
      def connection_strings(arg = nil)
        set_or_return(:connection_strings, arg, kind_of: [Array])
      end

      #
      # Hostname of the Sitecore site.
      #
      def hostname(arg = nil)
        set_or_return(:hostname, arg, kind_of: [String])
      end

      #
      # App Pool identity
      #
      def identity(arg = nil)
        set_or_return(:identity, arg, kind_of: [String])
      end

      #
      # Location from which to retrieve the license file.
      #
      def license(arg = nil)
        set_or_return(:license, arg, kind_of: [String])
      end

      #
      # Set the directory path where the site will be installed. Defaults
      # to c:/inetpub/wwwroot/#{name}.
      #
      def path(arg = nil)
        set_or_return(:path, arg, kind_of: [String])
      end

      #
      # Runtime version for the app pool.
      #
      def runtime_version(arg = nil)
        set_or_return(:runtime_version, arg, kind_of: [String])
      end

      #
      # Zip of Sitecore/Solr dlls. Gets expanded to the website bin dir.
      #
      def solr_libs(arg = nil)
        set_or_return(:solr_libs, arg, kind_of: [String])
      end

      #
      # Path to a zip containing Sitecore.
      #
      def source(arg = nil)
        set_or_return(:source, arg, kind_of: [String])
      end
    end
  end
end

class Chef
  class Provider
    #
    # Installs the Sitecore Content Management System.
    #
    class SitecoreCms < Chef::Provider
      include Chef::Mixin::PowershellOut
      include Sitecore::CmsHelper
      include Sitecore::FilesystemHelper
      include Sitecore::IISHelper

      def load_current_resource
        r = new_resource
        @current_resource ||= Resource::SitecoreCms.new(r.name)

        @current_resource.bindings(r.bindings)
        @current_resource.checksum(r.checksum)
        @current_resource.connection_strings(r.connection_strings)
        @current_resource.hostname(r.hostname)
        @current_resource.identity(r.identity)
        @current_resource.license(r.license)
        @current_resource.path(r.path)
        @current_resource.runtime_version(r.runtime_version)
        @current_resource.solr_libs(r.solr_libs)
        @current_resource.source(r.source)

        @current_resource
      end

      def action_install
        r = new_resource
        Chef::Log.info("Installing Sitecore to #{r.path}")
        zip = fetch_file(r.source, r.checksum)
        ::FileUtils::mkdir_p(r.path) unless ::Dir.exist?(r.path)
        set_sitecore_permissions(r.path)
        extract_sitecore_files(zip, r.path)
        configure_data_folder(web_config_path, data_path)
        write_connection_strings(connection_strings_path, r.connection_strings)
        create_app_pool(r.name, r.runtime_version, r.identity)
        create_iis_website(r.name, website_path, r.bindings[0])
        add_bindings(r.name, r.bindings)
        return if r.license.nil?
        place_license_file(r.license, data_path)
        configure_license_file(web_config_path, license_path)
      end

      def action_enable_solr
        r = new_resource
        solr_dll = ::File.join(website_path, 'bin',
                               'Sitecore.ContentSearch.SolrProvider.dll')
        return if r.solr_libs.nil? || ::File.exist?(solr_dll)
        Chef::Log.info("Enabling Solr for #{r.name}")
        remove_lucene_configs(website_path)
        zip = fetch_file(r.solr_libs)
        unzip_path = "#{zip}.extracted"
        unzip(zip, unzip_path)
        bin_dir = ::File.join(website_path, 'bin')
        ::FileUtils::cp_r(::File.join(unzip_path, '.'), bin_dir)
      end

      private

      def website_path
        @sc_website_path ||= ::File.join(new_resource.path, 'Website')
      end

      def data_path
        @sc_data_path ||= ::File.join(new_resource.path, 'Data')
      end

      def license_path
        @sc_license_path ||= ::File.join(data_path, 'license.xml')
      end

      def web_config_path
        @sc_web_config_path ||= ::File.join(website_path, 'web.config')
      end

      def connection_strings_path
        @sc_connection_strings_path ||= ::File.join(website_path, 'App_Config',
                                                    'connectionStrings.config')
      end

      def place_license_file(source, dest_folder)
        cached_license = fetch_file(source)
        return nil unless ::File.exist?(cached_license) &&
          ::File.directory?(dest_folder)
        dest = ::File.join(dest_folder, 'license.xml')
        f = Chef::Resource::File.new(dest, run_context)
        f.content(::File.open(cached_license).read)
        f.run_action(:create)
        dest
      end

      def configure_license_file(config_path, license_file_path)
        xpath = "sitecore/settings/setting[@name='LicenseFile']"
        safe_path = sitecore_safe_path(license_file_path)
        update_config_node(config_path, xpath, 'value', safe_path)
      end

      def configure_data_folder(config_path, data_folder_path)
        xpath = "sitecore/sc.variable[@name='dataFolder']"
        safe_path = sitecore_safe_path(data_folder_path)
        update_config_node(config_path, xpath, 'value', safe_path)
      end

      def write_connection_strings(path, dbs)
        return unless dbs.is_a?(Array) && dbs.length > 0
        t = Chef::Resource::Template.new(path, run_context)
        t.source('connectionStrings.config.erb')
        t.variables(databases: dbs)
        t.cookbook('sitecore')
        t.run_action(:create)
      end

      def extract_sitecore_files(zip, dest)
        if !::Dir[glob_safe_path(::File.join(dest, '*'))].empty?
          Chef::Log.info("Sitecore files already exist at #{dest}")
          return
        end

        unzip_path = "#{zip}.extracted"
        unzip(zip, unzip_path)
        container_glob = glob_safe_path("#{unzip_path}/[Ss]itecore*rev*/")
        container = ::Dir.glob(container_glob).first
        if container.nil?
          container = unzip_path
        end
        ::FileUtils.cp_r(::File.join(container, '.'), dest)
      end
    end
  end
end
