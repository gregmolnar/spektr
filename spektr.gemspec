require_relative 'lib/spektr/version'

Gem::Specification.new do |spec|
  spec.name = 'spektr'
  spec.version = Spektr::VERSION
  spec.authors = ['Greg Molnar']
  spec.email = ['molnargerg@gmail.com']

  spec.summary = 'Rails static code analyzer for security issues'
  spec.description = 'Rails static code analyzer for security issues'
  spec.homepage = 'https://railscop.com'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '> 6.1.0'
  spec.add_dependency 'erubi'
  spec.add_dependency 'haml', '~>5.1'
  spec.add_dependency 'parser', '~> 3.0.0'
  spec.add_dependency 'pastel'
  spec.add_dependency 'ruby_parser', '~>3.13'
  spec.add_dependency 'slim'
  spec.add_dependency 'tty-color'
  spec.add_dependency 'tty-option'
  spec.add_dependency 'tty-spinner'
  spec.add_dependency 'tty-table'
  spec.add_dependency 'unparser', '~> 0.6.0'
  spec.add_dependency 'zeitwerk'

  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-minitest'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop'
end
