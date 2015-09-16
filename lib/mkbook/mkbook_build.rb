module Mkbook
  class MkbookBuild < Mkbook
    self.abstract_command = true
    self.command = 'build'
    self.summary = '生成电子书'
    self.description = '生成各种格式的电子书'

    def run
      super
      puts "mkbook build #{self.class.command}"
    end

    class PDF < MkbookBuild
      self.summary = 'Generate pdf output'
    end

    class HTML < MkbookBuild
      self.summary = 'Generate html output'
    end

    class EPUB < MkbookBuild
      self.summary = 'Generate epub output'
    end

    class MOBI < MkbookBuild
      self.summary = 'Generate mobi output'
    end
  end
end
