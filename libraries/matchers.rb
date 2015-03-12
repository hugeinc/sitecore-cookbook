#
# Cookbook Name:: sitecore
# Library:: matchers
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

if defined?(ChefSpec)
  def install_sitecore_cms(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sitecore_cms, :install, resource_name)
  end

  def enable_solr_for_sitecore_cms(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sitecore_cms, :enable_solr, resource_name)
  end

  def enable_sitecore_config(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sitecore_config, :enable, resource_name)
  end

  def disable_sitecore_config(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sitecore_config, :disable, resource_name)
  end

  def install_sitecore_db(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sitecore_db, :install, resource_name)
  end

  def create_login_sitecore_db(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sitecore_db, :create_login, resource_name)
  end

  def assign_roles_sitecore_db(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:sitecore_db, :assign_roles, resource_name)
  end
end
