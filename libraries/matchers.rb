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
