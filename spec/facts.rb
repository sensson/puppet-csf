module Facts
  class << self
    attr_accessor :override_facts
  end
end

Facts.override_facts = {
  # Override/set concat_basedir
  concat_basedir: '/tmp/concat'
}
