class MrbgemTemplate
  def self.parse_options!(argv)
    options = { # default value
      license: "MIT",
      mrbgem_prefix: ".",
      github_user: detect_github_user,
      author: detect_author,
      local_builder: true,
      mruby_version: nil,
      ci: true,
    }
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: mrbgem-template [options] mrbgem_name"
      opts.version = MrbgemTemplate::VERSION

      opts.on("-h", "--help", "Show usage") do |v|
        puts opts.help
        exit 1
      end

      opts.on("-v", "--version", "Show version") do |v|
        puts "mrbgem-template version #{opts.version}"
        exit 1
      end

      opts.on("-l", "--license [LICENSE]", "Set license") do |v|
        options[:license] = v
      end

      opts.on("-u", "--github-user [USER]", "Set user name on github") do |v|
        options[:github_user] = v
      end

      opts.on("-p", "--mrbgem-prefix [PREFIX]", "Set prefix dir to mgem project") do |v|
        options[:mrbgem_prefix] = v
      end

      opts.on("-c", "--class-name [CLASS]", "Set class name") do |v|
        options[:class_name] = v
      end

      opts.on("-a", "--author [AUTHOR]", "Set the author of this mgem") do |v|
        options[:author] = v
      end

      opts.on("-m", "--mruby-version [VERSION]", "Set target mruby version") do |v|
        options[:mruby_version] = v
      end

      opts.on("-B", "--bin-name [BIN_NAME]", "Set and generate binary tools") do |v|
        options[:bin_name] = v
      end

      opts.on("-b", "--[no-]local-builder", "Enable or disable local builder") do |v|
        options[:local_builder] = v
      end

      opts.on("-C", "--[no-]ci", "Enable or disable CI by GitHub Actions") do |v|
        options[:ci] = v
      end
    end

    if argv.size <= 0
      puts parser.help
      exit 1
    end

    if argv[-1] !~ /\A-/
      options[:mrbgem_name] = argv.pop
      options[:class_name] = to_class_name(options[:mrbgem_name]) # This is also default
    end

    parser.parse!(argv)

    options
  end

  private
  def self.to_class_name(snake)
    snake = snake.sub(/\Amruby-/, '')
    next_camel_mark = true
    snake.chars.inject("") do |d, s|
      if next_camel_mark
        d += s.upcase
        next_camel_mark = false
      elsif s !~ /[a-zA-Z0-9]/
        next_camel_mark = true
      else
        d += s
        next_camel_mark = false
      end
      d
    end
  end

  def self.detect_github_user
    detected = `git config github.user`.chomp
    detected.empty? ? nil : detected
  end

  def self.detect_author
    detected = `git config user.name`.chomp
    detected.empty? ? nil : detected
  end
end
