require 'tty/option'
require 'json'
module Spektr
  class Cli
    include TTY::Option
    usage do
      program 'Spektr'
      command 'scan'
      desc 'Find vulnerabilities in ruby code'
    end

    argument :root do
      optional
      desc 'Path to application root'
    end

    flag :output_format do
      long '--output_format string'
      desc 'output format terminal or json'
      default 'terminal'
    end

    flag :check do
      long '--check string'
      desc 'run this single check'
    end

    flag :ignore do
      long '--ignore string'
      desc 'comma separated list of fingerprints to ignore'
    end

    flag :debug do
      long '--debug'
      short '-d'
      desc 'output debug logs to STDOUT'
    end

    flag :help do
      short '-h'
      long '--help'
      desc 'Print usage'
    end

    def scan
      if params[:help]
        print help
        exit
      else
        ignore = params[:ignore] ? params[:ignore].split(',') : []
        report = Spektr.run(params[:root], params[:output_format], params[:debug], params[:check], ignore)
        case params[:output_format]
        when 'json'
          puts JSON.pretty_generate report
          exit 1 if report[:advisories].any?
        end
      end
    end
  end
end
