name 'sitecore'
maintainer 'Huge'
maintainer_email 'sysops@hugeinc.com'
license 'Apache v2.0'
description 'Installs/Configures Sitecore'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.4.0'

depends 'windows', '~> 1.31'
depends 'powershell', '~> 3.0'
depends 'iis', '~> 2.1'
depends 'openssl', '~> 1.1'
depends 'git', '~> 4.0'
