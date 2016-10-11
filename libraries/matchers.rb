if defined?(ChefSpec)
  def create_ga_haproxy(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ga_haproxy, :create, resource_name)
  end

  def enable_ga_haproxy_frontend(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ga_haproxy_frontend, :enable, resource_name)
  end

  def disable_ga_haproxy_frontend(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ga_haproxy_frontend, :disable, resource_name)
  end

  def enable_ga_haproxy_backend(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ga_haproxy_backend, :enable, resource_name)
  end

  def disable_ga_haproxy_backend(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ga_haproxy_backend, :disable, resource_name)
  end
end
