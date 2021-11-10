require 'tty/option'
require 'json'
module Spektr
  class Cli
    include TTY::Option
    usage do
      program "Spektr"
      command "scan"
      desc "Find vulnerabilities in ruby code"
    end

    argument :root do
      optional
      desc "Path to application root"
    end

    flag :output_format do
      long "--output_format string"
      desc "output format terminal or json"
    end

    flag :help do
      short "-h"
      long "--help"
      desc "Print usage"
    end

    def scan
      if params[:help]
        print help
        exit
      else
        report = Spektr.run(params[:root], params[:output_format])
        case params[:output_format]
        when "json"
          puts JSON.pretty_generate report
        end
      end
    end
  end
end
