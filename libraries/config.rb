#
# Cookbook Name:: sitecore
# HWRP:: config
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

class Chef
  class Resource
    #
    # API for manipulating the Sitecore CMS configuration.
    #
    class SitecoreConfig < Chef::Resource
      identity_attr :name

      def initialize(name, run_context = nil)
        super
        @resource_name = :sitecore_config
        @provider = Chef::Provider::SitecoreConfig
        @action = :enable
        @allowed_actions = [:enable, :disable]
        @name = name
        @site = ''
        @configs_path = nil
        @returns = 0
      end

      #
      # Name of the Sitecore site.
      #
      def site(arg = nil)
        set_or_return(:site, arg, kind_of: [String])
      end

      #
      # Full path the App_Config\Include
      #
      def configs_path(arg = nil)
        set_or_return(:configs_path, arg, kind_of: [String])
      end
    end
  end
end

class Chef
  class Provider
    #
    # Manipulates Sitecore configuration.
    #
    class SitecoreConfig < Chef::Provider

      def load_current_resource
        r = new_resource
        @current_resource ||= Resource::SitecoreConfig.new(r.name)

        @current_resource.site(r.site)
        @current_resource.configs_path(r.configs_path)

        @current_resource
      end

      #
      # Enable a config file by removing the .disabled extension.
      #
      def action_enable
        if !::File.exists?(enabled_path)
          if ::File.exists?(disabled_path)
            ::File.rename disabled_path, enabled_path
          else
            Chef::Application.fatal! "#{disabled_path} not found"
          end
        end
        Chef::Log.info "Enabled #{enabled_path}"
      end

      #
      # Disable a config file by adding the .disabled extension.
      #
      def action_disable
        if ::File.exists?(enabled_path)
          ::File.rename enabled_path, disabled_path
          Chef::Log.info "Disabled #{enabled_path}"
        end
      end

      private

      def base_path
        @base_path ||= begin
          p = nil
          r = new_resource
          if !r.configs_path.nil? && !r.configs_path.empty?
            p = r.configs_path
          elsif !r.site.nil? && !r.site.empty?
            p = ::File.join(
              'C:', 'inetpub', 'wwwroot', r.site, 'Website', 'App_Config',
              'Include')
          else
            Chef::Application.fatal!("A site name or base configs path must" +
              "be given.")
          end
          p
        end
      end

      def enabled_path
        @enabled_path ||= ::File.join(
          base_path, new_resource.name) + '.config'
      end

      def disabled_path
        @disabled_path ||= enabled_path + '.disabled'
      end
    end
  end
end
