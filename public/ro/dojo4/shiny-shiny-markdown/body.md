all dojo4's rails application use markdown in some fashion.  following is the setup we have for the shiniest of shiny markdown configurations:

step one is suck in the require gems

````ruby

# Gemfile

gem 'redcarpet'
gem 'pygments.rb'



````

next, you might want a good utility method that wraps up a syntax highlighting class and common calling conventions

````ruby

# file: lib/util.rb

module Util
  # teh markdown support
  
  class SyntaxHighlighting < Redcarpet::Render::HTML
    def block_code(code, language)
      language = 'ruby' if language.to_s.strip.empty?
      Pygments.highlight(code, :lexer => language, :options => {:encoding => 'utf-8'})
    end
  end

  def markdown(*args, &block)
    @markdown ||=
      Redcarpet::Markdown.new(
        SyntaxHighlighting,

        :no_intra_emphasis   => true,
        :tables              => true,
        :fenced_code_blocks  => true,
        :autolink            => true,
        :strikethrough       => true,
        :lax_html_blocks     => true,
        :space_after_headers => true,
        :superscript         => true
      )

    if args.empty? and block.nil?
      @markdown
    else
      source = args.join
      return nil if source.blank?
      @markdown.render(source, &block).strip.sub(/\A<p>/,'').sub(/<\/p>\Z/,'').html_safe
    end
  end


  extend self
end

````

okay cool. you are now setup to process markdown, with syntax highlighting, like so:

````ruby

  Util.markdown(" * this\n* is\n * a\n* list ")
  
````

but, you know that's kind of expensive and we generally avoid doing it in the view.  instead, we cache both the raw markdown and markdown formatted markdown on our objects.  don't forget that you *need* to keep the raw markdown if you want to let the user re-edit it... 

````ruby
# file : app/models/post.rb

class Post
  include Mongoid::Document
  
  field :body_source, :type => String
  field :body, :type => String
  
  before_save do |post|
    if post.body_source.blank?
      post.body = nil
    else
      post.body = Util.markdown(post.body_source)
    end
  end
  
  def to_html
    body.html_safe
  end
end
   
   
````


one last awesome tidbit: some of us like writing simple views in markdown.  this initializer will let you create 'app/views/foo.md' and have rails just do the right thing, including processing the markdown through erb first which allows looping, conditionals, etc...


````ruby

# file: config/initializers/markdown_templates.rb

module MarkdownTemplateHandler
  def self.erb
    @erb ||= ActionView::Template.registered_template_handler(:erb)
  end

  def self.markdown(*args, &block)
    Util.markdown(*args, &block)
  end

  def self.call(template)
    template = erb.call(template)
    "MarkdownTemplateHandler.markdown.render(begin;#{ template };end).html_safe"
  end
end

ActionView::Template.register_template_handler(:md, MarkdownTemplateHandler)
ActionView::Template.register_template_handler(:markdown, MarkdownTemplateHandler)

````

let's you do


````

# file: app/views/markdown-is-awesome.md

* this
* is
* a
* list

and

<% ['so', 'is', 'this'].each do |word| %>

* <%= word %>

<% end %>

````

and there you have it: rails markdown-fu for with pygments powered syntax highlighting