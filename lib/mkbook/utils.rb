require 'replace'

module Mkbook
  class Utils
    def self.pre_pandoc(string)
      replace = Replace.new(string)
      replace.pre_pandoc_for_latex
      replace.string
    end

    def self.post_pandoc(string)
      replace = Replace.new(string)
      replace.post_pandoc_for_latex
      replace.string
    end

    def self.command_exists?(command)
      if File.executable?(command) then
        return command
      end
      ENV['PATH'].split(File::PATH_SEPARATOR).map do |path|
        cmd = "#{path}/#{command}"
        File.executable?(cmd) || File.executable?("#{cmd}.exe") || File.executable?("#{cmd}.cmd")
      end.inject { |a, b| a || b }
    end

    def self.log(type, msg)
      print "[#{type}] #{Time.now} #{msg}"
    end

    def self.log_info(msg)
      log("INFO", msg)
    end

    def self.log_error(msg)
      log("ERROR", msg)
    end

    def self.log_debug(msg)
      log("DEBUG", msg)
    end
  end
end
