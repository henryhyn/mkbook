require 'claide'
require 'colored'

module Mkbook
  class MakeBook < CLAide::Command
    self.abstract_command = true
    self.command = 'mkbook'
    self.description = '电子书生成工具'

    def run
      puts 'mkbook'
    end
  end
end
