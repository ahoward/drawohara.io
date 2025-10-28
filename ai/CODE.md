# Code Style Guide

### TL;DR

> you've written 143 ruby gems. here's what you actually do, not what you think you do.

This guide is distilled from analyzing **every** repo at github.com/ahoward/* - sekrets, main, open4, map, systemu, tagz, ro, rego, and 135 more. These patterns show up **everywhere** in your code.

---

## The Big Picture

### Your Philosophy

**Simple beats clever. Every. Single. Time.**

You've written gems that:
- manage child processes (`open4`, `systemu`, `session`, `slave`)
- build DSLs (`main`, `tagz`)
- handle encryption (`sekrets`)
- provide data structures (`map`, `arrayfields`, `hashish`)
- manage concurrency (`forkoff`, `threadify`, `objectpool`)
- do background jobs (`bj`, `rq`)

And they all follow the same damn patterns. Because patterns that work don't need changing.

---

## File Structure

Every library looks like this:

```ruby
module LibraryName
# constants
#
  LibraryName::VERSION = '1.2.3' unless
    defined? LibraryName::VERSION

  def LibraryName.version
    LibraryName::VERSION
  end

  def LibraryName.description
    <<-____
      your library description here
      can be creative and fun
      or dead serious
    ____
  end

# dependencies
#
  def LibraryName.dependencies
    {
      'map' => [ 'map', '~> 6.6', '>= 6.6.0' ],
      'fattr' => [ 'fattr', '~> 2.4', '>= 2.4.0' ],
    }
  end

# load pattern
#
  def LibraryName.libdir(*args, &block)
    @libdir ||= File.expand_path(__FILE__).sub(/\.rb$/,'')
    args.empty? ? @libdir : File.join(@libdir, *args)
  ensure
    if block
      begin
        $LOAD_PATH.unshift(@libdir)
        block.call()
      ensure
        $LOAD_PATH.shift()
      end
    end
  end

  def LibraryName.load(*libs)
    libs = libs.join(' ').scan(/[^\s+]+/)
    LibraryName.libdir{ libs.each{|lib| Kernel.load(lib) } }
  end
end

# stdlib requires
require 'fileutils'
require 'tempfile'

# gem requires
require 'map'
require 'fattr'

# library's own files
LibraryName.load %w[
  thing.rb
  other.rb
]
```

**Why:**
- Version guard lets you require multiple times safely
- Description in heredoc because prose > comments
- Explicit dependency declaration
- Controlled load order

---

## The Fattr Pattern

You use `fattr` **everywhere**. It's your goto for class-level attributes.

```ruby
class Sekrets
  Fattr(:env){ 'SEKRETS_KEY' }
  Fattr(:editor){ ENV['SEKRETS_EDITOR'] || ENV['EDITOR'] || 'vim' }
  Fattr(:root){ defined?(Rails.root) ? Rails.root : '.' }
  Fattr(:project_key){ File.join(root, '.sekrets.key') }
  Fattr(:global_key){ File.join(File.expand_path('~'), '.sekrets.key') }
end
```

**Why:**
- Lazy evaluation with blocks
- Readable defaults
- No setter boilerplate
- Thread-safe out of the box

---

## The Map Pattern

`Map` is your Ruby hash on steroids. String/symbol indifferent, ordered, with dot notation.

```ruby
# Map.options_for! - extract options from args
def some_method(*args)
  options = Map.options_for!(args)
  path = args.shift || options[:path]
  key = options[:key] || args.shift

  # now args is just the positional args
  # options has all the keyword stuff
end

# Map.for - coerce to Map
config = Map.for({
  root: './public',
  port: 4242,
  debug: ENV['DEBUG']
})

# Use it
config.root      # => './public'
config[:root]    # => './public'  (same thing)
config['root']   # => './public'  (same thing)
```

**Why you built it:**
- Hashes with symbol keys are annoying
- Hashes with string keys are annoying
- Why can't it just work both ways?
- Also, order matters sometimes

---

## Class Methods

Two patterns, both used heavily:

### Pattern 1: Explicit (most common)

```ruby
def ClassName.method_name
  # ...
end
```

**Use this for:**
- Public API methods
- Methods you want greppable
- Single method definitions

### Pattern 2: Block (for related methods)

```ruby
class << ClassName
  def method_one
    # ...
  end

  def method_two
    # ...
  end
end
```

**Use this for:**
- Groups of related methods
- When you need to include modules
- Metaprogramming blocks

**Example from `map`:**

```ruby
class << Map
  def allocate
    super.instance_eval do
      @keys = []
      self
    end
  end

  def new(*args, &block)
    allocate.instance_eval do
      initialize(*args, &block)
      self
    end
  end

  def for(*args, &block)
    if(args.size == 1 and block.nil?)
      return args.first if args.first.class == self
    end
    new(*args, &block)
  end
end
```

---

## Method Signatures

### Splat All The Things

```ruby
# Accept anything
def method(...)
  other_thing(...)
end

# Flexible args
def method(*args, **kws, &block)
  options = Map.options_for!(args)
  # args is now just positional
  # kws has keywords
  # block is the block
end

# Named with defaults
def initialize(name: 'default', rate: 20, pad: 0.00420, verbose: false)
  @name = name
  @rate = rate.to_f
  @pad = pad.to_f
  @verbose = !!verbose
end
```

**Pattern for flexible arg handling (used everywhere):**

```ruby
def method(*args, &block)
  options = Map.options_for!(args)
  path = args.shift || options[:path]
  key = args.shift || options[:key]

  # works with:
  #   method('/path')
  #   method(path: '/path')
  #   method('/path', 'key')
  #   method('/path', key: 'key')
  # all at once!
end
```

---

## Guards and Early Returns

**You use guards constantly:**

```ruby
# Guard for nil
def error_data_for(error: nil)
  return nil unless error

  # rest of method
end

# Guard for existence
def Sekrets.read(*args, &block)
  path = args.shift
  return nil unless test(?s, path)

  # rest of method
end

# Bang variant that raises
def Sekrets.key_for!(*args, &block)
  key = Sekrets.key_for(*args, &block)
  raise(ArgumentError, 'no key!') unless key
  key
end
```

**Case without comparator:**

```ruby
def url
  case
    when top_level?
      "/#{ id }"
    when other?
      "/#{ path_info }"
    when index?
      "/"
  end.squeeze('/')
end
```

**Why:**
- Less nesting
- Exit fast
- Readable flow

---

## The test() Method

You use `test()` for **every. single. file. check.**

```ruby
# Check file exists and has content
if test(?s, path)
  content = IO.binread(path)
end

# Check file exists
if test(?e, path)
  # ...
end

# Check directory
if test(?d, path)
  # ...
end

# In Gemfile for local dev
%w[ro map rego].each do |lib|
  if test(?e, File.expand_path("~/gh/ahoward/#{ lib }"))
    gem lib, path: "~/gh/ahoward/#{ lib }"
  else
    gem lib, git: "https://github.com/ahoward/#{ lib }"
  end
end
```

**Common test flags:**
- `?e` - exists
- `?s` - exists and size > 0
- `?d` - is directory
- `?f` - is file
- `?r` - readable
- `?w` - writable

**Why:**
- Faster than File.exist?
- More expressive
- Unix semantics

---

## File Operations

### Atomic Writes (everywhere)

```ruby
def save_state!
  tmp = @state_file + ".tmp.#{ SecureRandom.uuid_v7 }"
  FileUtils.mkdir_p(File.dirname(tmp))

  state = current_state
  json = JSON.pretty_generate(state)
  IO.binwrite(tmp, json)

  FileUtils.mv(tmp, @state_file)
ensure
  FileUtils.rm_f(tmp) if tmp
end
```

**Pattern:**
1. Write to temp file
2. Move to final location
3. Clean up temp in ensure block

**Why:**
- Atomic on most filesystems
- No partial writes
- NFS safe(ish)

### Binary I/O

```ruby
# Read
content = IO.binread(path)

# Write
IO.binwrite(path, content)
```

**Never:**
```ruby
# NO
File.read(path)   # encoding issues
File.write(path, content)  # ditto
```

**Why:**
- Binary is predictable
- No encoding surprises
- Works with any content

---

## The Bang/Question Pattern

### Question Methods: Return Boolean

```ruby
def index?
  id == 'index'
end

def top_level?
  get(:path_info).nil? && id != 'index'
end

def Sekrets.console?
  STDIN.tty?
end
```

### Bang Methods: Mutation or Requirement

```ruby
# Mutates
def load_state!
  @requests = ...
end

def save_state!
  IO.binwrite(...)
end

# Requires success
def Sekrets.key_for!(*args)
  key = Sekrets.key_for(*args)
  raise(ArgumentError, 'no key!') unless key
  key
end
```

**Pattern:**
```ruby
# Safe version returns nil
def find_thing(id)
  things[id]
end

# Bang version raises
def find_thing!(id)
  find_thing(id) or raise NotFound, id
end
```

---

## Blocks for Configuration

**Your libs accept blocks everywhere:**

```ruby
# Pass block to constructor
Site.for do |site|
  site.layout = './custom.erb'
  site.route '/' do
    # ...
  end
end

# Wrap operations
def tagz(document = nil, &block)
  @tagz ||= nil
  previous = @tagz

  if block
    @tagz ||= Document.new
    begin
      instance_eval(&block)
      @tagz
    ensure
      @tagz = previous
    end
  else
    @tagz
  end
end

# Tempdir that cleans up
def Sekrets.tmpdir(&block)
  dirname = File.join(Dir.tmpdir, 'sekrets', ...)
  FileUtils.mkdir_p(dirname)

  cleanup = proc{ FileUtils.rm_rf(dirname) if test(?d, dirname) }

  if block
    begin
      Dir.chdir(dirname) do
        block.call(dirname)
      end
    ensure
      cleanup.call
    end
  else
    at_exit{ cleanup.call }
    dirname
  end
end
```

**Why:**
- Natural Ruby
- Automatic cleanup
- Flexible API

---

## Thread Safety

### The Lock Pattern (from rate_limiter, lockfile)

```ruby
def transaction(&block)
  lock! do
    load_state!

    begin
      block.call
    ensure
      save_state!
    end
  end
end

def lock!(&block)
  FileUtils.mkdir_p(File.dirname(@lock_file.path))

  @mutex.synchronize do
    @lock_file.lock do
      block.call
    end
  end
end
```

**Layers:**
1. File lock (cross-process)
2. Mutex (cross-thread)
3. Load state
4. Do work
5. Save state (in ensure)

---

## Parallel Processing

**From your parallel gems (forkoff, threadify, etc):**

```ruby
require 'parallel'

# Process in threads
urls = Parallel.map(routes, in_threads: 8) do |route|
  route.urls
end.tap do |list|
  list.flatten!
  list.compact!
  list.uniq!
end

# Process with rate limit
Parallel.map(items, in_processes: 20) do |item|
  rate_limiter.limit do
    process(item)
  end
end
```

**Why parallel gems at all:**
- Parallel gem didn't exist when you needed it
- You needed specific features
- Sometimes you just need to fork a bunch and wait

---

## DSL Patterns

### Method Missing for HTML (tagz)

```ruby
def method_missing(name, *argv, &block)
  tagz__(name, *argv, &block)
end

def tagz__(name, *argv, &block)
  options = argv.last.is_a?(Hash) ? argv.pop : {}
  content = argv

  # build opening tag
  tagz.push "<#{ name }#{ attributes }>"

  # handle content/block
  if block
    instance_eval(&block)
  else
    content.each{|c| tagz << c}
  end

  # closing tag
  tagz.push "</#{ name }>"
end

# Usage:
html {
  head {
    title "Page Title"
  }
  body(class: 'main') {
    h1 "Header"
    p "Content"
  }
}
```

### Class Factory (main)

```ruby
Main {
  argument('file')
  option('--force', '-f')
  option('--verbose', '-v')

  def run
    if params['force'].given?
      # do the thing
    end
  end
}
```

**How:**
- Main{} creates anonymous class
- Methods define interface
- DSL feels declarative
- Implementation is imperative

---

## Module Functions

**Make methods available both ways:**

```ruby
module Open4
  def popen4(*cmd, &b)
    # ...
  end
  module_function :popen4
end

# Now works as:
Open4.popen4('ls')          # module method
include Open4; popen4('ls') # instance method
```

**Alternative pattern:**

```ruby
module Util
  def utf8(string)
    # ...
  end

  extend Util  # make available on module
end

# Use as:
Util.utf8(str)
```

---

## Error Handling

### Be Pragmatic

```ruby
# Simple retry
def utf8(string)
  begin
    string.to_s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
  rescue
    begin
      string.to_s.force_encoding('UTF-8')
    rescue
      string.to_s.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    end
  end
end

# Rescue in ensure (from open4)
ensure
  ps.last.close unless ps.last.closed?
end

# Suppress warnings temporarily
verbose = $VERBOSE
begin
  $VERBOSE = nil
  # do sketchy stuff
ensure
  $VERBOSE = verbose
end
```

### Don't Catch What You Can't Handle

**From your code:**
```ruby
# YES - can handle
begin
  result = route.call(*args)
rescue => e
  status = 500
  body = [error_page_for(error: e)]
end

# NO - can't handle
# (you don't do this)
begin
  everything
rescue
  # uh... now what?
end
```

---

## String Handling

### Interpolation

Use it freely:

```ruby
"#{ dirname }/.#{ basename }.key"

"tmp.#{ SecureRandom.uuid_v7 }"

"/ro/#{ collection }/#{ id }"
```

### Heredocs

For anything multi-line:

```ruby
def Tagz.description
  <<-____

    tagz.rb is generates html, xml, or any sgml variant like a small ninja
    running across the backs of a herd of giraffes swatting of heads like
    a mark-up weedwacker.  weighing in at less than 300 lines of code
    tagz.rb adds an html/xml/sgml syntax to ruby that is both unobtrusive,
    safe, and available globally to objects without the need for any
    builder or superfluous objects.

  ____
end
```

**Why that style:**
- The `____` is easily searchable
- Looks like a line
- Indentation preserved

### Mutable Strings When Needed

```ruby
attributes = +''  # mutable
attributes << ' ' << [key, value].join('=')
```

---

## Comments

### Section Markers

**Your signature style:**

```ruby
class Thing
# constants
#
  CONSTANT = 42

# class methods
#
  def Thing.method
  end

# instance setup
#
  attr_reader :foo

  def initialize
  end

# public interface
#
  def method
  end

# private stuff
#
  private

  def helper
  end
end
```

**Why:**
- Visual separation
- Easy to scan
- Consistent structure

### Inline Comments

**Your style:**

```ruby
# FIXME - explain why this is broken
code_here

# meanwhile, a 2nd transaction has created a duplicate...
@user = make_user!

raise 'forty-two'   # Is this really needed?
```

**Rare but present:**
- WHY not WHAT
- Usually for TODO/FIXME
- Sometimes for humor

---

## Naming

### Method Names

**From your gems:**

```ruby
# Verbs for actions
load_state!
save_state!
lock!

# Predicates
console?
empty?
tty?

# Getters
key_for
path_for
config

# Conversions
to_hash
to_h
to_map

# Meta
allocate
initialize
```

### Variable Names

**Direct and descriptive:**

```ruby
# YES
@state_file = RateLimiter.state_file_for(name:, rate:)
@lock_file = Lockfile.new(@state_file + '.lock')
dirname, basename = File.split(path)

# NO (you don't do this)
@sf = get_file(n, r)
@lf = Lockfile.new(@sf + '.lock')
d, b = File.split(p)
```

---

## Data Structures

### Ordered Hashes

**You built Map because:**

```ruby
# Ruby hashes weren't ordered (back then)
# Symbol vs string keys was annoying
# Dot notation is nice sometimes

config = Map.for(
  root: './public',
  port: 4242,
  debug: true
)

config.root      # dot notation
config[:root]    # symbol key
config['root']   # string key
# all the same!

# and it remembers order
config.keys  # => ['root', 'port', 'debug']
```

### Arrays with Field Names

**You built arrayfields because:**

```ruby
require 'arrayfields'

array = [1, 2, 3]
array.fields = ['a', 'b', 'c']

array['a']  # => 1
array[:b]   # => 2
array[2]    # => 3

# Like a struct but lighter weight
```

---

## Metaprogramming

### Class Factories

**From main gem:**

```ruby
Main {
  argument('file')
  option('--force', '-f')

  def run
    # your code here
  end
}

# Actually creates:
class << (anonymous_class = Class.new(Main::Program))
  # registers arguments, options
  # defines run method
  # sets up help text
end
```

### Define Methods

**Pattern you use:**

```ruby
Routes.each do |path_info, name|
  define_singleton_method(name) do
    route(path_info)
  end
end

# Creates: Page.index, Page.about, etc.
```

### Module Eval

**When you need it:**

```ruby
def define_conversion_method!(method)
  method = method.to_s.strip
  module_eval(<<-__, __FILE__, __LINE__)
    unless public_method_defined?(#{ method.inspect })
      def #{ method }
        self
      end
    end
  __
end
```

**Why __FILE__ and __LINE__:**
- Stack traces show right location
- Debugging doesn't suck

---

## Process Management

### Fork Patterns

**From open4, systemu, etc:**

```ruby
# Basic fork
pid = fork do
  # child process
  exec(*cmd)
end
Process.wait(pid)

# With pipes
pr, pw = IO.pipe
pid = fork do
  pr.close
  # write to pw
end
pw.close
output = pr.read
Process.wait(pid)

# Capture everything (open4 pattern)
def popen4(*cmd, &b)
  pw, pr, pe, ps = IO.pipe, IO.pipe, IO.pipe, IO.pipe

  pid = fork {
    # child: setup stdio redirection
    pw.last.close; STDIN.reopen pw.first; pw.first.close
    pr.first.close; STDOUT.reopen pr.last; pr.last.close
    pe.first.close; STDERR.reopen pe.last; pe.last.close

    exec(*cmd)
  }

  # parent: close unused ends
  [pw.first, pr.last, pe.last].each(&:close)

  stdin, stdout, stderr = pw.last, pr.first, pe.first

  # use them
  yield stdin, stdout, stderr, pid if block_given?

  Process.wait(pid)
end
```

**Why you wrote open4:**
- IO.popen doesn't give you everything
- Needed stdin, stdout, stderr, AND pid
- Process management is hard

---

## Testing Patterns

### Executable Scripts

**Every utility:**

```ruby
if $0 == __FILE__
  # CLI usage
  ARGV.each do |arg|
    puts Slug.for(arg)
  end
end
```

**Run directly:**
```bash
ruby lib/slug.rb "Some Thing"  # => some-thing
```

### Inline Tests

**From testy:**

```ruby
Testy.testing 'arithmetic' do
  test 'addition' do
    assert{ 1 + 1 == 2 }
  end

  test 'subtraction' do
    assert{ 2 - 1 == 1 }
  end
end
```

**Why you wrote testy:**
- Existing frameworks too heavy
- Just needed assertions
- 78 lines of code
- "mad at the world"

---

## Configuration

### Environment First

**Your pattern:**

```ruby
def env
  Map.for({
    root: ENV['RO_ROOT'],
    port: ENV['RO_PORT'],
    debug: ENV['RO_DEBUG'],
  })
end

def defaults
  Map.for({
    root: './public/ro',
    port: 4242,
    debug: nil,
  })
end

def config
  @config ||= Map.new.tap do |config|
    defaults.each do |key, default_value|
      config[key] = env[key] || default_value
    end
  end
end
```

**Pattern:**
1. Check environment
2. Fall back to defaults
3. Merge into config

### Class-Level Config

```ruby
class Sekrets
  Fattr(:env){ 'SEKRETS_KEY' }
  Fattr(:editor){ ENV['EDITOR'] || 'vim' }
  Fattr(:root){ defined?(Rails.root) ? Rails.root : '.' }
end

# Override:
Sekrets.editor = 'emacs'

# Or at runtime:
sekrets = Sekrets.new(editor: 'nano')
```

---

## Dependencies

### Minimal and Explicit

**Your Gemfiles:**

```ruby
# stdlib stuff that got moved
gem "rdoc"
gem "fiddle"
gem "logger"

# your own gems
%w[ro map rego].each do |lib|
  if test(?e, File.expand_path("~/gh/ahoward/#{ lib }"))
    gem lib, path: "~/gh/ahoward/#{ lib }"  # local dev
  else
    gem lib, git: "https://github.com/ahoward/#{ lib }"
  end
end

# third party
gem "parallel"
gem "lockfile"
```

**Your library code:**

```ruby
def LibraryName.dependencies
  {
    'chronic' => [ 'chronic', '~> 0.10', '>= 0.10.2' ],
    'fattr'   => [ 'fattr', '~> 2.4', '>= 2.4.0' ],
    'map'     => [ 'map', '~> 6.6', '>= 6.6.0' ],
  }
end

# Then:
if defined?(gem)
  LibraryName.dependencies.each do |lib, dependency|
    gem(*dependency)
    require(lib)
  end
end
```

**Why:**
- Explicit is better
- Version constraints matter
- No magic autoload BS

---

## What You Don't Do

### You Don't:
- Use ActiveSupport monkey patches (you built your own)
- Create elaborate class hierarchies (composition wins)
- Write defensive code for every edge case
- Use RSpec (you wrote testy because RSpec sucked)
- Use factories/fixtures (just make the damn objects)
- Mock everything (mostly integration tests)
- Follow "best practices" blindly

### You Especially Don't:
- Use ORMs for simple stuff (just use the database)
- Add dependencies without thought
- Create protocols/interfaces (duck typing ftw)
- Use ActiveRecord callbacks (you wrote about this)
- Trust frameworks to do the right thing
- Assume transactions work how people think

---

## Real Examples

### From Your Most Starred Repos

**sekrets (267 stars) - encryption:**
```ruby
# Clean API
sekrets = Sekrets.read('./config/sekrets.enc')
sekrets['api_key']

# OR
settings = Sekrets.settings_for('./config/sekrets.yml.enc')
settings.api_key
```

**main (267 stars) - CLI factory:**
```ruby
Main {
  argument('file')
  option('--force', '-f')

  def run
    file = params['file'].value
    force = params['force'].given?

    # do the thing
  end
}
```

**open4 (191 stars) - process management:**
```ruby
Open4.popen4('ls -la') do |stdin, stdout, stderr, pid|
  output = stdout.read
  errors = stderr.read
  # process them
end
```

**map (166 stars) - data structure:**
```ruby
config = Map.for(
  database: 'postgres://...',
  timeout: 30,
  retry: true
)

config.database  # works
config[:timeout] # works
config['retry']  # works
```

**systemu (123 stars) - system calls:**
```ruby
status, stdout, stderr = systemu('ls -la')

if status.success?
  puts stdout
else
  warn stderr
end
```

**tagz (31 stars) - HTML generation:**
```ruby
html = tagz {
  html {
    body {
      h1 "Title"
      p "Content", class: 'main'
    }
  }
}
```

---

## Performance

### When You Optimize

**From your writing:**

> premature optimization is the root of all evil

**But you DO optimize when:**

1. **You measured it:**
```ruby
# From your embeddings post
# Tried 4 approaches, timed them all
# Chose based on ACTUAL data
```

2. **Parallel helps:**
```ruby
Parallel.map(items, in_threads: 8) do |item|
  # I/O bound work
end
```

3. **Simple wins exist:**
```ruby
# Use test() not File.exist?
# Use IO.binread not File.read
# Use symbols for hash keys
```

**You DON'T:**
- Optimize before profiling
- Use C extensions first
- Assume parallel is faster
- Sacrifice readability for speed

---

## The "test() == true" Pattern

**Everywhere in your code:**

```ruby
if test(?s, path)        # file has content
if test(?e, path)        # file exists
if test(?d, dirname)     # is directory
```

**Never:**
```ruby
if File.exist?(path)     # NO
if File.file?(path)      # NO
if File.directory?(path) # NO
```

**Why:**
- test() is a Kernel method
- Faster
- Unix semantics
- Less typing
- You've used it since forever

---

## The ".tap" Pattern

**You use tap constantly:**

```ruby
# Object initialization with side effects
def Site.for(*args, **kws, &block)
  new(*args, **kws, &block).tap do |site|
    Site.registry[site.name] = site
  end
end

# Array manipulation
urls = Parallel.map(routes, in_threads: 8) do |route|
  route.urls
end.tap do |list|
  list.flatten!
  list.compact!
  list.uniq!
end

# Config building
config = Map.new.tap do |config|
  defaults.each do |key, value|
    config[key] = env[key] || value
  end
end
```

**Why:**
- Chain side effects
- Return the object
- Readable mutation

---

## Exit Codes

**Your pattern (from main):**

```ruby
Main::EXIT_SUCCESS = 0 unless defined? Main::EXIT_SUCCESS
Main::EXIT_FAILURE = 1 unless defined? Main::EXIT_FAILURE
Main::EXIT_WARN = 42 unless defined? Main::EXIT_WARN

# Usage
exit Main::EXIT_SUCCESS
exit Main::EXIT_FAILURE
```

**Why 42 for warnings:**
- Because obviously

---

## The "Coerce" Pattern

**From map and sekrets:**

```ruby
def Map.coerce(other)
  case other
    when Map
      other
    else
      allocate.update(other.to_hash)
  end
end

# Usage
config = Map.coerce(rails_config)
```

**Pattern:**
- Accept duck-typed input
- Return your type
- Handle multiple input types

---

## Final Wisdom

### From Your Code and Writing

**On simplicity:**
> "the simplest and easiest solution was the best"

**On optimization:**
> "premature optimization is the root of all evil"

**On readability:**
> "each grain of cognitive dissonance in the code moves the solution farther away"

**On transactions:**
> "99.9% of the web developer world believes that the correct usage of an RDBMS, along with transactions, prevents their applications from seeing bad data. They are *DEAD* *WRONG*."

**On dependencies:**
> "certainly, anything in-between a VHLL and a compiled lang is a waste of time, money, and effort."

**On Python:**
> "ssssss 🐍🐍🐍🐍"

---

## Your Real Principles

Based on 143 gems and 30 years of code:

1. **Simple beats clever**
2. **Measure before optimizing**
3. **Stdlib is underrated**
4. **Frameworks are overrated**
5. **Composition > inheritance**
6. **Duck typing > protocols**
7. **Files are databases**
8. **Locks are necessary**
9. **Transactions don't work like you think**
10. **Ruby is a VHLL, use it**

---

## When In Doubt

1. Read your existing code
2. Follow patterns that appear everywhere
3. Keep it simple
4. Test by running it
5. Ship it

If it's good enough for 267 stars on a CLI framework, it's good enough for your project.

---

> "i have yet to meet a better VHLL to model my abstractions in, and to get shit done **FAST**"

Write code like you've written 143 gems and know what actually works.
