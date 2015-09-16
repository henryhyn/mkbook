module Mkbook
  class MakeBookBuild < MakeBook
    self.abstract_command = true
    self.command = 'build'
    self.summary = '生成电子书'
    self.description = '生成各种格式的电子书'

    def run
      super
      puts "mkbook build #{self.class.command}"
    end

    class PDF < MakeBookBuild
      self.summary = 'Generate pdf output'
    end

    class HTML < MakeBookBuild
      self.summary = 'Generate html output'
    end

    class EPUB < MakeBookBuild
      self.summary = 'Generate epub output'
    end

    class MOBI < MakeBookBuild
      self.summary = 'Generate mobi output'
    end
  end
end
