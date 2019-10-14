lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-tag-normaliser"
  spec.version = "0.1.1"
  spec.authors = ["Banzai Cloud"]
  spec.email   = ["info@banzaicloud.com"]

  spec.summary       = %q{Tag-normaliser is a `fluentd` plugin to help re-tag logs with Kubernetes metadata.}
  spec.description   = %q{Tag-normaliser is a `fluentd` plugin to help re-tag logs with Kubernetes metadata. It uses special placeholders to change tag.}
  spec.homepage      = "https://github.com/banzaicloud/fluent-plugin-tag-normaliser"
  spec.license       = "Apache-2.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
end
