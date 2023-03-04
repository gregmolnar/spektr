# frozen_string_literal: true

require 'bundler'
require 'parser'
require 'parser/current'
require 'erb'
require 'haml'
require 'logger'
require 'tty/spinner'
require 'tty/table'
require 'spektr/core_ext/string'
require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.collapse("#{__dir__}/processors")
loader.do_not_eager_load("#{__dir__}/spektr/core_ext")
loader.setup

module Spektr
  class Error < StandardError; end

  def self.run(root = nil, output_format = 'terminal', debug = false, checks = nil, ignore = [])
    pastel = Pastel.new
    @output_format = output_format
    start_spinner('Initializing')
    @log_level = if debug
      Logger::DEBUG
    elsif terminal?
      Logger::ERROR
    else
      Logger::WARN
    end
    checks = Checks.load(checks)
    root = './' if root.nil?
    @app = App.new(checks: checks, root: root, ignore: ignore)
    stop_spinner
    if terminal?
      puts "\n"
      puts pastel.bold('Checks:')
      puts "\n"
      puts checks.collect(&:name).join(', ')
      puts "\n"
    end

    start_spinner('Loading files')
    @app.load
    stop_spinner
    table = TTY::Table.new([
                             ['Rails version', @app.rails_version],
                             ['Initializers', @app.initializers.size],
                             ['Controllers', @app.controllers.size],
                             ['Models', @app.models.size],
                             ['Views', @app.views.size],
                             ['Routes', @app.routes.size],
                             ['Lib files', @app.lib_files.size]
                           ])
    if terminal?
      puts "\n"
      puts table.render(:basic)
      puts "\n"
    end
    start_spinner('Scanning files')
    @app.scan!
    stop_spinner
    puts "\n"
    json = @app.report

    case output_format
    when 'json'
      json
    when 'terminal'
      puts pastel.bold("Advisories\n")

      json[:advisories].each do |advisory|
        puts "#{pastel.green('Name:')} #{advisory[:name]}\n"
        puts "#{pastel.green('Check:')} #{advisory[:check]}\n"
        puts "#{pastel.green('Description:')} #{advisory[:description]}\n"
        puts "#{pastel.green('Path:')} #{advisory[:path]}\n"
        puts "#{pastel.green('Location:')} #{advisory[:location]}\n"
        puts "#{pastel.green('Code:')} #{advisory[:line]}\n"
        puts "#{pastel.green('Fingerprint:')} #{advisory[:fingerprint]}\n"
        puts "\n"
        puts "\n"
      end

      puts pastel.bold("Summary\n")
      summary = []
      json[:advisories].group_by { |a| a[:name] }.each do |n, i|
        summary << [pastel.green(n), i.size]
      end

      table = TTY::Table.new(summary, padding: [2, 2, 2, 2])
      puts table.render(:basic)
      puts "\n\n"
      exit 1 if json[:advisories].any?
    else
      puts 'Unknown format'
    end
  end

  def self.terminal?
    @output_format == 'terminal'
  end

  def self.start_spinner(label)
    return unless terminal?

    @spinner = TTY::Spinner.new("[:spinner] #{label}", format: :classic)
    @spinner.auto_spin
  end

  def self.stop_spinner
    return unless terminal?

    @spinner&.stop('Done!')
  end

  def self.swap_spinner(label)
    stop_spinner
    start_spinner(label)
  end

  def self.logger
    @logger ||= begin
      logger = Logger.new($stdout)
      logger.level = @log_level || Logger::WARN
      logger
    end
  end
end
