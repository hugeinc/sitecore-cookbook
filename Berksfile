source "https://supermarket.getchef.com"

metadata
cookbook 'windows', '~> 1.31'
cookbook 'powershell', '~> 3.0'
cookbook 'iis', '~> 2.1'
cookbook 'git', '~> 4.0'

group :dev do
  cookbook 'min_config', path: 'spec/support/cookbooks/min_config'
  cookbook 'configure_cms', path: 'spec/support/cookbooks/configure_cms'
  cookbook 'advanced_config', path: 'spec/support/cookbooks/advanced_config'
end