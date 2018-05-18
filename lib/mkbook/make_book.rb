require 'erb'
require 'yaml'
require 'mkbook/utils'

module Mkbook
  class MakeBook
    HERE = Dir.getwd
    ROOT = File.dirname(__FILE__)
    TEMPLATE = File.join(ROOT, "..", "template")
    SETTING_FILE = ".mkbook.yml"

    def initializes(params)
      @project = params[:project]
      @setting_file = File.join(@project, SETTING_FILE)
      @setting_file = File.join(TEMPLATE, SETTING_FILE) unless File.exist?(@setting_file)
      @setting = YAML.load_file(@setting_file)
      @setting.merge!(params)
      @setting[:name] ||= File.basename(@project)
      load
    end

    def self.find(params)
      book = new
      book.initializes(params)
      book
    end

    def create(params)
      @project = File.join(params[:workspace], params[:name])
      @setting_file = File.join(TEMPLATE, SETTING_FILE)
      @setting = YAML.load_file(@setting_file)
      @setting.merge!(params)
      @setting[:name] ||= File.basename(@project)
      load
      save
    end

    def build(params)
      @project = params[:dir_source]
      @setting_file = File.join(@project, SETTING_FILE)
      @setting = YAML.load_file(@setting_file)
      @setting = {} unless @setting
      @setting.merge!(params)
      @setting[:name] ||= File.basename(@project)
      load
      check_environment
      load_config
      @setting[:build].each do |fmt|
        case fmt
          when 'pdf' then
            @preface  = markdown2latex(@file_preface)
            @chapters = markdown2latex(@file_chapters)
            @appendix = markdown2latex(@file_appendix)
            generate_main_file
            latex2pdf
          when 'index' then
            index = {}
            index[:preface] = markdown2index(@file_preface)
            index[:chapters]= markdown2index(@file_chapters)
            index[:appendix]= markdown2index(@file_appendix)
            FileUtils.mkdir_p(@dir_html) unless Dir.exist?(@dir_html)
            IO.write(File.join(@dir_html, 'index.yml'), index.to_yaml)
          when 'html' then
            markdown2html(@file_preface)
            markdown2html(@file_chapters)
            markdown2html(@file_appendix)
        end
      end
      save_config
      save_setting
    end

    def load
      @name           = @setting[:name]
      @lang           = @setting[:lang]
      @genre          = @setting[:genre]
      @debug          = @setting[:debug]
      @final          = @setting[:final]
      @option         = @setting[:option]
      @format         = @setting[:format] || 'markdown'
      @template       = @setting[:template]
      @dir_output     = @setting[:dir_output] || File.join(@project, "out")
      @dir_latex      = File.join(@dir_output, ".tex")
      @dir_html       = File.join(@dir_output, "html")
      @file_preface   = @setting[:file_preface]
      @file_chapters  = @setting[:file_chapters]
      @file_appendix  = @setting[:file_appendix]
    end

    def save
      Utils.log_info("Generate project #{@name.upcase}\n")
      mkdir
      mkdir("src")
      mkdir("images")
      touch("images", ".keep")
      mkdir("resources")
      touch("resources", ".keep")
      touch(".gitignore")
      save_setting
    end

    def mkdir(*string)
      target = File.join(@project, string)
      file = File.join(@name, string)
      unless Dir.exist?(target)
        puts "\t\033[32mcreate\033[0m #{file}"
        FileUtils.mkdir_p(target)
      else
        puts "\t\033[31mexists\033[0m #{file}"
      end
    end

    def touch(*string)
      if string.length < 3
        source = File.join(TEMPLATE, string)
        target = File.join(@project, string)
      else
        source = File.join(TEMPLATE, string[0..-2])
        string.delete_at(-2)
        string[0] = "src"
        target = File.join(@project, string)
      end
      file = File.join(@name, string)
      unless File.exist?(target)
        puts "\t\033[32mcreate\033[0m #{file}"
        template = ERB.new(File.read(source))
        IO.write(target, template.result(binding))
      else
        puts "\t\033[31mexists\033[0m #{file}"
      end
    end

    def get_name(template, name=nil)
      prefix = template[0..3]
      rank = get_rank(prefix)
      name = template[9..-4] if name.nil?
      "#{prefix}#{rank}-#{name}.md"
    end

    def get_rank(prefix)
      Dir.chdir(File.join(@project, "src"))
      num = Dir["#{prefix}*"].length + 10
      100*num
    end

    def add(template, name)
      name = get_name(template, name)
      touch(@lang, template, name)
    end

    def list_template
      Dir.chdir(File.join(TEMPLATE, @lang))
      Dir["*.md"]
    end

    def check_environment
      missing = ['pandoc', 'xelatex'].reject { |command| Utils.command_exists?(command) }
      unless missing.empty?
        Utils.log_error "Missing dependencies: #{missing.join(', ')}."
        puts "\n\tInstall these and try again."
        exit
      end
    end

    def load_config
      @config_file = File.join(ROOT, "config.yml")
      if File.exists? @config_file
        configs = YAML.load_file(@config_file)
        @config = configs["default"]
        @config.merge!(configs[@lang]) if configs[@lang]
      end

      @config_file = File.join(@project, "src", "config.yml")
      if File.exists? @config_file
        configs = YAML.load_file(@config_file)
        @config.merge!(configs) if configs
      end
    end

    def save_config
      IO.write(@config_file, @config.to_yaml)
    end

    def save_setting
      @setting.delete(:command)
      @setting.delete(:dir_source)
      @setting.delete(:dir_output)
      @setting.delete(:dir_latex)
      @setting.delete(:workspace)
      @setting.delete(:project)
      @setting.delete(:final)
      @setting.delete(:debug)
      @setting_file = File.join(@project, SETTING_FILE)
      IO.write(@setting_file, @setting.to_yaml)
    end

    def markdown2latex(regex)
      Dir.chdir(@project)
      files = File.join("src", regex)

      Utils.log_info("Parsing markdown ... #{files}:\n")
      markdown = Dir["#{files}"].sort.map do |file|
        puts "\t\033[32minclude\033[0m #{file}"
        IO.read(file)
      end.join("\n\n")

      Utils.log_info("Convert markdown into latex ... ")
      latex = IO.popen("pandoc --wrap=none --top-level-division=chapter -f #{@format} -t latex", 'w+') do |pipe|
        pipe.write(Utils.pre_pandoc(markdown))
        pipe.close_write
        Utils.post_pandoc(pipe.read)
      end
      puts "done"

      return latex
    end

    def markdown2index(regex)
      Dir.chdir(@project)
      files = File.join("src", regex)

      Utils.log_info("Indexing markdown ... #{files}:\n")
      index_string = []
      Dir["#{files}"].sort.map do |file|
        title_raw = IO.readlines(file)[0]
        title = if title_raw.nil? || title_raw.strip.empty?
                  '未命名'
                else
                  title_raw
                      .chomp                      # 删除换行符
                      .gsub(/^#+\s*/, '')         # 删除行首的 # 号
                      .gsub(/\s*\{.*?\}\s*$/, '') # 删除行尾的标识符
                      .gsub(/\s*#+\s*$/, '')      # 删除行尾的 # 号
                end
        name = file.gsub(/^src\//, '')
        index_string << {name: name, title: title}
      end
      index_string
    end

    def markdown2html(regex)
      Dir.chdir(@project)
      FileUtils.mkdir_p(@dir_html) unless Dir.exist?(@dir_html)
      files = File.join("src", regex)

      Utils.log_info("Parsing markdown ... #{files}:\n")
      Dir["#{files}"].sort.map do |file|
        puts "\t\033[32mconvert\033[0m #{file}"
        markdown = IO.read(file)
        html = IO.popen("pandoc --wrap=none --top-level-division=chapter -f #{@format} -t html", 'w+') do |pipe|
          pipe.write(markdown)
          pipe.close_write
          pipe.read
        end
        IO.write(File.join(@dir_html, "#{File.basename(file, '.md')}.htm"), html)
      end
    end

    def generate_main_file
      Dir.chdir(@project)
      FileUtils.mkdir_p(@dir_latex) unless Dir.exist?(@dir_latex)

      Utils.log_info("Generate main.tex file ...\n")
      target = File.join(@dir_latex, "main.tex")
      source = File.join(ROOT, "template_#{@template}.tex")
      template = ERB.new(File.read(source))
      IO.write(target, template.result(binding))
    end

    def latex2pdf
      Dir.chdir(@project)
      Dir.mkdir(@dir_output) unless Dir.exist?(@dir_output)

      Utils.log_info("Run xelatex main.tex ...\n")
      num = @final ? 2 : 1
      num.times do |i|
        IO.popen("xelatex -output-directory='#{@dir_latex}' #{@dir_latex}/main.tex 2>&1") do |pipe|
          while line = pipe.gets
            STDERR.print line if @debug
          end
        end
        Utils.log_info("Run xelatex main.tex #{i+1} time(s).\n")
      end
      Utils.log_info("Generate PDF Complete!\n")

      source = File.join(@dir_latex,  "main.pdf")
      target = File.join(@dir_output, "#{@name}.#{@lang}.pdf")
      Utils.log_info("Moving output to #{target}.\n")
      FileUtils.cp(source, target)
    end

    def show
      puts @project
    end
  end
end
