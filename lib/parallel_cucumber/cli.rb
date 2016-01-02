require 'json'
require 'optparse'

module ParallelCucumber
  module Cli
    class << self
      DEFAULTS = {
        n: 1,
        thread_delay: 0,
        env_variables: {}
      }

      def run(argv)
        options = parse_options!(argv)

        ParallelCucumber.run_tests_in_parallel(options)
      end

      private

      def parse_options!(argv)
        options = DEFAULTS.dup

        option_parser = OptionParser.new do |opts|
          opts.banner = [
            'Usage: parallel_cucumber [options] [ [FILE|DIR|URL][:LINE[:LINE]*] ]',
            'Example: parallel_cucumber -n 4 -o "-f pretty -f html -o report.html" examples/i18n/en/features'
          ].join("\n")
          opts.on('-n [PROCESSES]', Integer, 'How many processes to use') { |n| options[:n] = n }
          opts.on('-o', '--cucumber-options "[OPTIONS]"', 'Run cucumber with these options') do |cucumber_options|
            options[:cucumber_options] = cucumber_options
          end
          opts.on('-e', '--env-variables [JSON]', 'Set additional environment variables to processes') do |env_vars|
            options[:env_variables] = begin
              JSON.parse(env_vars)
            rescue JSON::ParserError
              puts 'Additional environment variables not in JSON format. And do not forget to escape quotes'
              exit 1
            end
          end
          opts.on('-s', '--setup-script [SCRIPT]', 'Execute SCRIPT before each process') do |script|
            fail("File '#{script}' does not exist") unless File.exist?(script)
            fail("File '#{script}' is not executable") unless File.executable?(script)
            options[:setup_script] = File.expand_path(script)
          end
          opts.on('--thread-delay [SECONDS]', Integer, 'Delay before next thread starting') do |thread_delay|
            options[:thread_delay] = thread_delay
          end
          opts.on('-v', '--version', 'Show version') do
            puts ParallelCucumber::VERSION
            exit 0
          end
          opts.on('-h', '--help', 'Show this') do
            puts opts
            exit 0
          end
        end

        option_parser.parse!(argv)
        options[:cucumber_args] = argv

        options
      rescue OptionParser::InvalidOption => e
        puts "Unknown option #{e}"
        puts option_parser.help
        exit 1
      end
    end # class
  end # Cli
end # ParallelCucumber
