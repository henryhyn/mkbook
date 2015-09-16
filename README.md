# mkbook

电子书生成解决方案.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mkbook'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mkbook


## 使用方法

### 创建项目

使用选项 `-g`, 并指定项目名, 即可在当前目录下创建一个电子书项目.

```
mkbook -g <name>
```

使用选项 `-w`, 并指定工作目录, 即可在指定目录下创建一个电子书项目, 默认为当前目录.

```
mkbook -g <name> -w <workspace>
```

### 构建项目

进入电子书项目所在目录, 执行 `mkbook` 命令, 即可构建当前电子书项目.
构建成功以后, 默认生成结果将保存到项目所在目录下的 `out` 文件夹中.
判定当前目录是否为一个电子书项目的依据是, 是否存在 `.mkbook.yml` 文件.

使用选项 `-d`, 以调试模式执行构建任务, 可以看到更多的输出结果, 在排错时非常有用.

```
mkbook -d
```

使用选项 `-s`, 指定项目所在目录;
使用选项 `-o`, 指定项目输出目录.

```
mkbook -s <dir_source> -o <dir_output>
```

构建任务也可以在 Ruby 脚本中, 按如下方式执行

```
require 'mkbook/make_book'
Mkbook::MakeBook.find(:dir_source => dir, :dir_output => dir).build
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mkbook. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

