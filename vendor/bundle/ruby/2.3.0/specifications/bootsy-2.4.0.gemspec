# -*- encoding: utf-8 -*-
# stub: bootsy 2.4.0 ruby lib

Gem::Specification.new do |s|
  s.name = "bootsy".freeze
  s.version = "2.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Volmer Campos Soares".freeze]
  s.date = "2017-03-03"
  s.description = "A beautiful WYSIWYG editor with image uploads for Rails.".freeze
  s.email = ["rubygems@radicaos.com".freeze]
  s.homepage = "http://github.com/volmer/bootsy".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "2.5.2.1".freeze
  s.summary = "A beautiful WYSIWYG editor with image uploads for Rails.".freeze

  s.installed_by_version = "2.5.2.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mini_magick>.freeze, ["~> 4.6"])
      s.add_runtime_dependency(%q<carrierwave>.freeze, ["~> 1.0"])
    else
      s.add_dependency(%q<mini_magick>.freeze, ["~> 4.6"])
      s.add_dependency(%q<carrierwave>.freeze, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<mini_magick>.freeze, ["~> 4.6"])
    s.add_dependency(%q<carrierwave>.freeze, ["~> 1.0"])
  end
end
