require 'digest/sha1'
require 'yaml'
require 'fileutils'
require 'base64'

class YKK
  @instance = self.new

  def self.method_missing(method, *args, &block)
    if @instance.respond_to?(method)
      @instance.__send__(method, *args, &block)
    else
      super
    end
  end

  def self.inspect
    @instance.inspect
  end

  attr_accessor :dir, :searchable

  def initialize(dir = nil, searchable = false)
    self.dir = dir
    self.searchable = searchable
  end

  def <<(value)
    key = key_gen(value)
    self[key] = value
    key
  end

  def [](key)
    path = file_of(key)
    return nil unless File.exists?(path)
    YAML.load(File.read(path))
  end

  def key?(key)
    !!self[key]
  end

  NGRAM_N = 2
  NGRAM_PREFIX = '_ngram_'

  def []=(key, value)
    path = file_of(key)
    dirname = File.dirname(path)
    FileUtils.mkdir_p(dirname) unless File.exists?(dirname)
    y = value.to_yaml
    y.force_encoding(Encoding::UTF_8) unless /\A1.8/ === RUBY_VERSION # FIXME
    File.open(path, 'wb') { |f| f << y }
    ngram_gen(y, NGRAM_N, key) if searchable
  end

  def ngram_path(a)
    File.join(dir, "#{NGRAM_PREFIX}#{Base64.encode64(a).chomp.tr('-', '+')}")
  end

  def ngram_func(text, n)
    text.split(//u).each_cons(n).map(&:join).uniq.each do |a|
      yield a
    end
  end

  def ngram_gen(text, n, key)
    ngram_func(text, n) do |a|
      File.open(ngram_path(a), 'a') { |f| f.puts(key) }
    end
  end

  def search(q)
    paths = []
    ngram_func(q, NGRAM_N) do |a|
      paths << ngram_path(a)
    end
    keychains = paths.uniq.map do |path|
      return [] unless File.exist?(path)
      File.open(path) { |f| f.readlines.uniq.map(&:chomp) }
    end
    keychain = keychains.reduce { |x, y| x & y }
    keychain.select do |key|
      path = file_of(key)
      next unless File.exists?(path)
      !File.read(path).index(q).nil?
    end
  end

  def delete(key)
    path = file_of(key)
    File.delete(path) if File.exists?(path)
    nil
  end

  def file_of(key)
    key = key.to_s
    raise ArgumentError, 'invalid key' unless key =~ /^[\w\/]+$/
    raise "dir is not specified" unless dir
    File.join(dir, key)
  end

  def key_gen(value)
    Digest::SHA1.hexdigest(value.to_yaml)
  end

  def inspect
    pairs = Dir.glob(dir + '/*').map {|f|
      "#{File.basename(f).inspect}: #{YAML.load_file(f).inspect}"
    }
    "YKK(#{pairs.join ', '})"
  end
end
