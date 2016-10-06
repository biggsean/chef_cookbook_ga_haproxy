if defined?(ChefSpec)
  def create_ga_haproxy(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:ga_haproxy, :create, resource_name)
  end
end
