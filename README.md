# Sitecore Cookbook

Cookbook to install the [Sitecore 7.x content management system](http://www.sitecore.net/).

# About

This cookbook implements resources useful for installing and/or configuring Sitecore:

The **sitecore_cms** resource installs the files, sets permissions, and makes IIS configurations
for serving a website powered by Sitecore. There's also an optional action to enable the Solr
content search provider.

The **sitecore_config** resource enables and disables settings in the App_Config\Includes directory.

The **sitecore_db** resource attaches the Sitecore databases, creates a user account, and grants
it permissions on those DBs.

These resource can be used together to spin up a VM on a developer workstation, or independently
to provision separate database & application server nodes in other environments.

There's also an IIS helper recipe which can be used to quickly install some common features.
This recipe is optional and you're welcome to set up IIS however you like as long as it has
all the requirements for Sitecore 7.

This cookbook expands on some of the ideas found in the
[Sitecore Powershell Library](https://github.com/Sitecore/PowerShell-Script-Library).

Neither the Sitecore CMS, Windows, nor a license file are included with this cookbook. Users are
responsible for obtaining and licensing the proprietary bits of a Sitecore tech stack on their own.
The licensing of this cookbook does not apply to Sitecore or Windows.

This cookbook references proprietary software. See [NOTICE](NOTICE) for more information.

# Requirements

- Chef 11.10 or higher
- Ruby 1.9 or higher
- Windows
    - Tested with Windows Server 2012
- IIS
    - Tested with IIS 8
- SQL Server
    - Tested with SQL Server 2012 and SQL Server Express 2014
- Powershell with SQL Server Management Objects

# Attributes

Attributes live in `node['sitecore']`. Read the source code in attributes/ to see what attributes are
available, and their default values.

# Resource/Provider Usage

## sitecore_cms

Installs Sitecore to inetpub, creates an IIS website and app pool.

Paths to assets such as the sitecore zip, license file, etc... can be local, i.e. you've
placed them in a temporary location using chef resources such as
[cookbook_file](https://docs.getchef.com/resource_cookbook_file.html), or remote,
such as a secured and restricted URL accessible by Chef.

### Example Usage

    sitecore_cms 'MySite' do
      source 'c:/path/to/sitecore7.zip'
      license 'c:/path/to/license.xml'
      bindings [
        { 'host' => 'example.com', 'proto' => 'http', 'port' => 80 }
      ]
      connection_strings [
        {
          'name' => 'core',
          'database' => 'Sitecore.Core',
          'user_id' => 'sitecore_user',
          'password' => 'foobar123',
          'data_source' => '(local)\SQLEXPRESS'
        },
        {
          'name' => 'master',
          'database' => 'Sitecore.Master',
          'user_id' => 'sitecore_user',
          'password' => 'foobar123',
          'data_source' => '(local)\SQLEXPRESS'
        },
        {
          'name' => 'web',
          'database' => 'Sitecore.Web',
          'user_id' => 'sitecore_user',
          'password' => 'foobar123',
          'data_source' => '(local)\SQLEXPRESS'
        },
        {
          'name' => 'analytics',
          'connection_string' => 'mongodb://mongodb/analytics'
        }
      ]
    end

### Example of using the Solr content search provider

    sitecore_cms 'MySite' do
      action [:install, :enable_solr]
      source 'c:/path/to/sitecore7.zip'
      solr_libs 'c:/path/to/solr_libs.zip'
      bindings [
        # My site's bindings
      ]
      connection_strings [
        # My site's connection strings
      ]
      license 'c:/path/to/license.xml'
    end

In this example we add the `:enable_solr` action and supply the path to a zip file
of Sitecore's Solr dlls, which will be placed in the website's bin directory, i.e.
c:/inetpub/wwwroot/mysite/website/bin.

## sitecore_config

Enables or disables configuration files. If the name of a site is given, the
provider will look in the default location of
c:\inetpub\wwwroot\SiteName\App_Config\Include. The full path to your includes
directory can be specified via the `configs_path` attribute.

If both `site` and `configs_path` are given, `configs_path` takes precedence.

### Example Usage

    sitecore_config 'Sitecore.Mvc' do
      site 'MySite'
      action :enable
    end

    sitecore_config 'Sitecore.MvcAnalytics' do
      configs_path 'D:\MySite\App_Config\Includes'
      action :disable
    end

## sitecore_db

Sets up one or more Sitecore databases.

Assumes that SQL Server is present, and the account running Chef has
permission to create databases, users, and assign roles. If you're using
vagrant, this means the vagrant user on your development box.

### Example Usage

    sitecore_db '.\SQLEXPRESS' do
      action [:install, :create_login, :assign_roles]
      site 'MySite'
      databases [
        { 'name' => 'Sitecore.Core', 'type' => 'core' },
        { 'name' => 'Sitecore.Master', 'type' => 'master' },
        { 'name' => 'Sitecore.Web', 'type' => 'web' },
        { 'name' => 'Sitecore.Analytics', 'type' => 'analytics' }
      ]
      source_directory 'c:/inetpub/wwwroot/MySite/Databases'
      username 'sitecore_user'
      password 'foobar123'
    end

This resource will look for mdf and ldf files corresponding to each
`database` name in the `source_directory` and attach them to the
SQL server at `.\SQLEXPRESS` (or whichever host you provide).

A login named "sitecore_user" will be created with the given password,
and granted the roles defined in `node['sitecore']['roles']`.

Refer to
"[Evolution of Cookbook Development](https://www.getchef.com/blog/2014/02/03/evolution-of-cookbook-development/)"
by Opscode for information on handling sensitive data with Chef.

# Recipes

**default** recipe takes no action.

**iis** recipe is included as a tool for setting up the roles needed to serve a
Sitecore site. Using it is optional, and you're welcome to implement your own
logic for configuring IIS.

# Testing

Use Rspec to execute the ChefSpec tests:

    $ rspec

# Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for help with problems commonly encountered by users of this cookbook. If that document doesn't address your situation, feel free to [open an issue on Github](https://github.com/hugeinc/sitecore-cookbook/issues).

# How to contribute

Please read [CONTRIBUTING.md](CONTRIBUTING.md) to learn how you can help improve this cookbook.

# Authors

- Huge (<sysops@hugeinc.com>)
- Tom Harrison ([@tomharrison](http://twitter.com/tomharrison))

# License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
