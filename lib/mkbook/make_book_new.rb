module Mkbook
  class MakeBookNew < MakeBook
    self.command = 'new'
    self.summary = '新建电子书'
    self.description = '新建一个电子书项目'

    def run
      super
      puts 'mkbook new'
    end
  end
end
