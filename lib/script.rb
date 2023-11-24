#! /usr/bin/env ruby

#
#   # example script
#   #
#     ~> cat ./script/a.rb
#
#     #! /usr/bin/env ruby
#     #  encoding: utf-8

#
#     script do
#       help <<~____
#         NAME
#           # FIXME
#
#         TL;DR;
#           # FIXME
#       ____
#
#       run do
#         p [@mode, @argv, @options]
#       end
#
#       run(:foo) do
#         p [@mode, @argv, @options]
#       end
#
#       run(:bar) do
#         p [@mode, @argv, @options]
#       end
#     end
#
#
#     BEGIN {
#       require_relative '../lib/script.rb'
#     }
#
#   # example usage
#   #
#     ~> ./script/a.rb arg1 arg2 k:v K=v a: A:
#     [nil, ["arg1", "arg2"], {"k"=>"v", "K"=>"v", "a"=>true, "A"=>true}]
#
#     ~> ./script/a.rb foo arg1 arg2 k:v K=v a: A:
#     ["foo", ["arg1", "arg2"], {"k"=>"v", "K"=>"v", "a"=>true, "A"=>true}]
#
#     ~> ./script/a.rb bar arg1 arg2 k:v K=v a: A:
#     ["bar", ["arg1", "arg2"], {"k"=>"v", "K"=>"v", "a"=>true, "A"=>true}]
#
#     ~> ./script/a.rb =m ==n ===o ====p
#     [nil, [], {"m"=>true, "n"=>false, "o"=>true, "p"=>false}]
#

require 'json'
require 'yaml'
require 'base64'
require 'securerandom'
require 'fileutils'
require 'pathname'
require 'openssl'
require 'uri'
require 'cgi'
require 'shellwords'
require 'tmpdir'
require 'tempfile'

require_relative 'say'

def script(*args, &block)
  Script.run!(*args, &block)
end

class Script
  attr_accessor :source, :root, :env, :argv, :stdout, :stdin, :stderr, :help

  def run!(env = ENV, argv = ARGV)
    setup!(env, argv)
    parse_command_line!
    set_mode!
    run_mode!
  end

  def setup!(env, argv)
    @klass = self.class
    @env = env.to_hash.dup
    @argv = argv.map { |arg| arg.dup }
    @stdout = $stdout.dup
    @stdin = $stdin.dup
    @stderr = $stderr.dup
    @help = @klass.help || Util.unindent(DEFAULT_HELP)
  end

  DEFAULT_HELP = <<-__
      NAME
        #TODO

      SYNOPSIS
        #TODO
      #{'   '}
      DESCRIPTION
        #TODO
      #{'   '}
      EXAMPLES
        #TODO
  __

  def parse_command_line!
    @options = {}

    argv = []
    head = []
    tail = []

    %w[@@ --].each do |stop|
      next unless (i = @argv.index(stop))

      head = @argv.slice(0...i)
      tail = @argv.slice((i + 1)...@argv.size)
      @argv = head
      break
    end

    @argv.each do |arg|
      if arg =~ /^\s*@([^@\s]+)=(.+)/
        key = ::Regexp.last_match(1)
        val = ::Regexp.last_match(2)
        @options[key] = val
      elsif arg =~ /^\s*(@+)(.+)/
        switch = ::Regexp.last_match(1)
        key = ::Regexp.last_match(2)
        val = switch.size.odd?
        @options[key] = val
      else
        argv.push(arg)
      end
    end

    u.symbolize_keys!(@options)

    argv += tail

    @argv.replace(argv)
  end

  def set_mode!
    @mode = (@argv.shift if respond_to?("run_#{@argv[0]}!"))
  end

  def run_mode!
    if @mode
      send("run_#{@mode}!")
    else
      run
    end
  end

  def run
    if @argv.empty?
      run_help!
    else
      abort("#{$0} help")
    end
  end

  def run_help!
    STDOUT.puts(@help)
  end

  def help!
    run_help!
    abort
  end

  utils =
    %w[
      log
      err
      lock!
    ]

  utils.each do |method|
    eval "def #{method}(...); Util.#{method}(...); end"
  end

  module Util
    def unindent(arg)
      string = arg.to_s.dup
      margin = nil
      string.each_line do |line|
        next if line =~ /^\s*$/

        margin = line[/^\s*/] and break
      end
      string.gsub!(/^#{margin}/, '') if margin
      margin ? string : nil
    end

    def esc(*args)
      args.flatten.compact.map { |arg| Shellwords.escape(arg) }.join(' ')
    end

    def uuid
      SecureRandom.uuid
    end

    def tmpname(*args)
      opts = extract_options!(*args)

      base = opts.fetch(:base) { uuid }.to_s.strip
      ext = opts.fetch(:ext) { 'tmp' }.to_s.strip.sub(/^[.]+/, '')
      basename = opts.fetch(:basename) { "#{base}.#{ext}" }

      File.join(Dir.tmpdir, basename)
    end

    def tmpfile(*args, &block)
      opts = extract_options!(args)

      path = tmpname(opts)

      tmp = open(path, 'w+')
      tmp.binmode
      tmp.sync = true

      unless args.empty?
        src = args.join
        tmp.write(src)
        tmp.flush
        tmp.rewind
      end

      if block
        begin
          block.call(tmp)
        ensure
          FileUtils.rm_rf(path)
        end
      else
        at_exit { Kernel.system("rm -rf #{esc(path)}") }
        tmp
      end
    end

    def extract_options!(args)
      args = [args] unless args.is_a?(Array)

      opts = args.last.is_a?(Hash) ? args.pop : {}

      symbolize_keys!(opts)

      opts
    end

    def extract_options(args)
      opts = extract_options!(args)

      args.push(opts)

      opts
    end

    def symbolize_keys!(hash)
      hash.keys.each do |key|
        val = hash.delete(key)

        symbolize_keys!(val) if val.is_a?(Hash)

        hash[key.to_s.gsub('-', '_').to_sym] = val
      end

      hash
    end

    def symbolize_keys(hash)
      symbolize_keys(copy(hash))
    end

    def copy(object)
      Marshal.load(Marshal.dump(object))
    end

    def debug?
      ENV['DEBUG']
    end

    def debug!(arg)
      return unless debug?

      if arg.is_a?(String)
        warn "[script.rb] #{arg}"
      else
        warn "[script.rb] #{arg.inspect}"
      end
    end

    def log(*messages, io: $stdout)
      ts = Time.now.utc.iso8601
      prefix = File.basename(__FILE__)
      msg = messages.join("\n\t").strip

      io.write "---\n[#{prefix}@#{ts}]\n\t#{msg}\n\n\n"

      begin
        io.flush
      rescue StandardError
        nil
      end
    end

    def err(*messages, io: $stderr)
      log(*messages, io:)
    end

    def lock!(&block)
      path = eval('__FILE__', block.binding, __FILE__, __LINE__)

      File.open(path) do |fd|
        locked = fd.flock(File::LOCK_EX | File::LOCK_NB)

        if locked
          block.call
        else
          err 'already running'
          exit 42
        end
      end
    end

    def sys!(*args, &block)
      opts = extract_options!(args)

      cmd = args

      debug!(cmd:)

      open3 = (
        block ||
        opts[:stdin] ||
        opts[:quiet] ||
        opts[:capture]
      )

      if open3
        stdin = opts[:stdin]
        stdout = ''
        stderr = ''
        status = nil

        Open3.popen3(*cmd) do |i, o, e, t|
          ot = async_reader_thread_for(o, stdout)
          et = async_reader_thread_for(e, stderr)

          i.write(stdin) if stdin
          i.close

          ot.join
          et.join

          status = t.value
        end

        if status.exitstatus == 0
          result = nil

          if opts[:capture]
            stdout.to_s.strip
          elsif block
            block.call(status, stdout, stderr)
          else
            [status, stdout, stderr]
          end

        else
          abort("#{[cmd].join(' ')} #=> #{status.exitstatus}")
        end
      else
        system(*cmd) || abort("#{[cmd].join(' ')} #=> #{$?.exitstatus}")
        true
      end
    end

    def sys(*args, &block)
      sys!(*args, &block)
    rescue Object
      false
    end

    def async_reader_thread_for(io, accum)
      Thread.new(io, accum) do |i, a|
        Thread.current.abort_on_exception = true

        while true
          buf = i.read(8192)

          break unless buf

          a << buf

        end
      end
    end

    def realpath(path)
      Pathname.new(path.to_s).expand_path.realpath.to_s
    end

    def filelist(*args, &block)
      accum = (block || proc { Set.new }).call
      raise ArgumentError, 'accum.class != Set' unless accum.is_a?(Set)

      _ = args.last.is_a?(Hash) ? args.pop : {}

      entries = args.flatten.compact.map { |arg| realpath("#{arg}") }.uniq.sort

      entries.each do |entry|
        if test('f', entry)
          file = realpath(entry)
          accum << file

        elsif test('d', entry)
          glob = File.join(entry, '**/**')

          Dir.glob(glob) do |_entry|
            if test('f', _entry)
              filelist(_entry) { accum }
            elsif test('d', entry)
              filelist(_entry) { accum }
            end
          end
        end
      end

      accum.to_a
    end

    def expandenv!(file)
      result = Result.new
      return result unless test('s', file) && test('f', file)

      buf = IO.binread(file)
      var = /[$]\s*{\s*([0-9a-zA-Z_-]+)(?::-([^}]+))?\s*}/iomx

      buf.gsub!(var) do
        key = ::Regexp.last_match(1)
        val = (ENV[key] || ::Regexp.last_match(2))

        if val
          val = val.to_s.strip
          result[key] = val
          result.success = true
          val
        else
          result[key] = nil
          ''
        end
      end

      IO.binwrite(file, buf) if result.success?

      result
    end

    def slug_for(*args, &block)
      Slug.for(*args, &block)
    end

    extend Util
  end

  def self.utils(&block)
    block ? Util.module_eval(&block) : Util
  end

  def utils
    Util
  end

  def u
    Util
  end

  class Slug < ::String
    Join = '-'

    def self.for(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}

      join = (options[:join] || options['join'] || Join).to_s

      string = args.flatten.compact.join(' ')

      tokens = string.scan(/[^\s#{join}]+/)

      tokens.map! do |token|
        token.gsub(%r`[^\p{L}/.]`, '').downcase
      end

      tokens.map! do |token|
        token.gsub(%r{[/.]}, join * 2)
      end

      tokens.join(join)
    end
  end

  class Result < Hash
    def success
      if defined?(@status)
        @status == :success
      else
        (!empty? and values.all?)
      end
    end

    def success=(bool)
      bool = !!bool
      if bool
        :success
      else
        :failure
      end
    end

    alias success? success

    def failure
      if defined?(@status)
        @status == :failure
      else
        (empty? or values.none?)
      end
    end

    def failure=(bool)
      bool = !!bool
      if bool
        :failure
      else
        :success
      end
    end

    alias failure? failure

    def status
      return @status if defined?(@status)
    end

    def status=(bool)
      @status = !!bool
    end

    alias status? status
  end

  def noop
    ENV['NOOP']
  end

  alias noop? noop

  def self.help(*args)
    @help ||= nil

    @help = utils.unindent(args.join) unless args.empty?

    @help
  end

  def self.run(*args, &block)
    modes =
      if args.empty?
        [nil]
      else
        args
      end

    modes.each do |mode|
      method_name =
        if mode
          "run_#{mode}!"
        else
          'run'
        end

      define_method(method_name, &block)
    end
  end

  def self.klass_for(&block)
    Class.new(Script) do |klass|
      def name = 'Script::Klass'
      klass.class_eval(&block)
    end
  end

  def self.run!(*args, &block)
    STDOUT.sync = true
    STDERR.sync = true

    %w[PIPE INT].each { |signal| Signal.trap(signal, 'EXIT') }

    script = (
      source =
        if binding.respond_to?(:source_location)
          File.expand_path(binding.source_location.first)
        else
          File.expand_path(eval('__FILE__', block.binding, __FILE__, __LINE__))
        end

      root = File.dirname(source)

      klass = Script.klass_for(&block)

      instance = klass.new

      instance.source = source
      instance.root = root

      instance
    )

    script.run!(*args)
  end
end

BEGIN {
  Object.send(:remove_const, :Script) if Object.const_defined?(:Script)

  def Script(*args, &block)
    script(*args, &block)
  end
}

if $0 == __FILE__
  template = <<~________
    #! /usr/bin/env ruby
    #  encoding: utf-8

    require_relative '../lib/script.rb'

    script do
      help <<~____
        NAME
          # FIXME

        TL;DR;
          # FIXME
      ____

      run do
        p [@mode, @argv, @options]
      end

      run(:foo) do
        p [@mode, @argv, @options]
      end

      run(:bar) do
        p [@mode, @argv, @options]
      end
    end
  ________

  puts template
end
