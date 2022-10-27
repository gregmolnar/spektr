# Spektr

[![Ruby CI](https://github.com/gregmolnar/spektr/actions/workflows/ci.yaml/badge.svg?branch=master)](https://github.com/gregmolnar/spektr/actions/workflows/ci.yaml)

Spektr is a static-code analyser for Ruby On Rails applications to find security issues.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spektr'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install spektr

## Usage

If you are using in your app:

```
spektr
```

If you want to scan an app in another folder:

```
spektr path/to/app
```

To see the available options, you can run `spektr --help`.

To ignore a finding, you can use the `--ignore` flag with a comma separated list of fingerprints from the report.


### Railsgoat Example output

![Railgoat example](https://github.com/gregmolnar/spektr/blob/master/railsgoat-example.png)

### False positives

Due to the nature of static-code analysis, Spektr might report false positives. Please report them, so I can try
to tweak the check.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gregmolnar/spektr. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/gregmolnar/spektr/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms described in the [licence](https://github.com/gregmolnar/spektr/blob/master/LICENSE.txt). Non-commercial use is free of charge, to obtain a commercial licence, contact us at info[at]spektrhq.com.
If you are looking for a hosted solution, take a look at [SpektrHQ](https://spektrhq.com).


## Code of Conduct

Everyone interacting in the Spektr project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/gregmolnar/spektr/blob/master/CODE_OF_CONDUCT.md).

## FAQ

### I use Spektr in my closed-source paid product making millions of dollars, is that non-commercial use?

Yes, this is perfectly fine without obtaining a licence. You can however donate to the development here on Github.

### I want to use Spektr in my automated code analyser SaaS, do I need a commercial licence?

Yes, please get in touch at info[at]spektrhq.com and we will work something out.

### I am a penetration tester and I'd like to use Spektr to audit on a paid engagement. Do I need a commercial licence?

No. You are free to use it for that purpose, happy bug hunting!
