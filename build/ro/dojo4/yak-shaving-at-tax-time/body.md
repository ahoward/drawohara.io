i wrote this script while doing my taxes because, like all good programmers, i'd rather write a tool than use a bloody spreadsheet program


it saves me from

* having to use a spreadsheet to categorize my taxes

and, additionally it saves me from having to use a spreadsheet to categorize my taxes

with out further ado (that's for you @steve)

<br>
<br>

````ruby
#! /usr/bin/env ruby

require 'csv'
require 'pp'
require 'readline'
require 'fileutils'

require 'rubygems'

require 'main'
require 'coerce'
require 'arrayfields'

Main {
  synopsis <<-__

    ruby categorize.rb transactions.csv

    ruby categorize.rb transactions.csv --continue # where i left off...

  __

  description <<-__

    categorize is a damn transaction categorizing damn script i wrote doing my damn taxes

    it works on a csv that looks like

      Transaction Number,Date,Description,Memo,Amount Debit,Amount Credit ,Balance,Check Number,Fees  
      "20121231000000[-7:MST]*-9.99*42**Withdrawal",12/31/2012,"Withdrawal","Amazon Video On Demand 866-216-1072 WA Date 12/29/12 000031828826 5735",-9.99, ,"492.93",,
      "20121231000000[-7:MST]*-4000.00*12**Withdrawal Home Banking",12/31/2012,"Withdrawal Home Banking","Transfer To HOWARD,ARA T 0000133543 Share 0008 Online Banking Transfer Dec. 31, 2012 09:37 Ref: 325989",-4000.00, ,"502.92",,
      "20121231000000[-7:MST]*4393.89*501**Deposit DOJO4 LLC",12/31/2012,"Deposit DOJO4 LLC","TYPE: QUICKBOOKS ID: 1722616653 CO: DOJO4 LLC",,4393.89 ,"4502.92",,
      "20121227000000[-7:MST]*-17.99*42**Withdrawal",12/27/2012,"Withdrawal","WWW.RDIOCHARGE.COM 877-7346843 CA Date 12/26/12 900017146258 8699",-17.99, ,"122.02",,
      ...

    a lot of banks can export these

    after using it the file will look something like this

      TRANSACTION_NUMBER,DATE,DESCRIPTION,MEMO,AMOUNT_DEBIT,AMOUNT_CREDIT,BALANCE,CHECK_NUMBER,FEES,CATEGORY
      20121015000000[-7:MST]*-3.00*21**Transfer fee,10/15/2012,Transfer fee,"",-3.00,"",9.99,,,fee
      ...

    which is to say it'll have a CATEGORY column and all rows categorized

    it really doesn't care about the data too much, needing just one field to
    sort by.  by default this is the 'Memo' field but the script doesn't
    really care if it's missing.  besides, you can specifi the sort field with
    '--sort' and you'll probably want to because the default mode rememers
    your last selection and provides it as a default as you're editing
    categories.

    note that the script clobbers in the input file destructively, so make a
    backup if you really care.  well, it does, but still, know that it
    clobbers to allow continuing an editing session.

  __

  argument(:transactions)

  option(:continue, :c)

  option(:sort, :s){
    default 'MEMO'
  }

  option(:categories){
    default <<-__

      expense/client
      expense/client/meals
      expense/client/entertainment

      expense/office
      expense/office/internet
      expense/office/phone
      expense/office/supplies
      expense/office/maintenance

      expense/software
      expense/software/service
      expense/software/license

      expense/hardware

      income
      payroll
      transfer
      loan
      fee

      beer

      uncategorized
    __
  }

  def run
  # setup
  #
    @categories = Coerce.list_of_strings(params[:categories].values)
    @transactions = params[:transactions].value

    @fields = [] 
    @rows = []

  # parse the data and massage it a little
  #
    CSV.parse(IO.read(@transactions)) do |row|
      row = row.map{|cell| cell ? cell.strip : cell}
      next unless row.detect{|value| value}

      if @fields.empty?
        @fields = row.map{|cell| cell.strip.upcase.gsub(/\s+/, '_')}
        @fields.push('CATEGORY') unless @fields.include?('CATEGORY')
      else
        row = row.map{|cell| cell ? cell.strip : cell}
        row.fields = @fields
        @rows.push(row)
      end
    end

    sort_key = params[:sort].value
    @rows.sort!{|a, b| a[sort_key] <=> b[sort_key]}

  # auto-save on exit magic-ness-ish
  #
    save = proc do
      begin
        buf = CSV.generate{|csv| csv << @fields; @rows.each{|row| csv << row}}
        open("#{ @transactions }.tmp", "wb+"){|fd| fd.write(buf)}
        FileUtils.mv(@transactions, "#{ @transactions }.bak")
        FileUtils.mv("#{ @transactions }.tmp", @transactions)
      rescue Object => e
        STDERR.puts "#{ e.message }(#{ e.class })\n#{ Array(e.backtrace).join(10.chr) }"
      end
    end
    at_exit{ save.call() }
    trap('SIGINT'){ puts; exit(0) }

  # setup teh readlinez to auto-complete our categories
  #
    Readline.completion_append_character = ' '
    Readline.completion_proc = proc do |string|
      re = /#{ Regexp.escape(string) }/
      candidates = @categories.grep(re)
    end

  # during edit we'll track the last entered category and keep it as a sane
  # default when <enter> is pressed.  when combined with sorting this makes
  # editing big blocks if similar entires real quick.
  #
    current_category = nil

  # ok edit dat shit
  #
    @rows.each do |row|
    # skip to the first un-categorized row iff --continue given...
    #
      if params[:continue].given?
        next if !row[:CATEGORY].to_s.strip.empty?
      end

    # grok the with of the header/row so we can print them out at the same
    # width and avoid breaking our eyes.  this is pretty much a hacky way to
    # do this
    #
      header = @fields.map{|field| "#{ field }"}
      row.each_with_index do |cell, index|
        header[index] << ' ' until header[index].to_s.size >= cell.to_s.size
      end

      copy = proc do |object|
        Marshal.load(Marshal.dump(object))
      end

      formatted = proc do |array|
        array = copy[array]
        array.fields = @fields

        header.each_with_index do |field, index|
          array[index] ||= ''
          array[index] << ' ' until array[index].to_s.size >= header[index].size
        end

        array
      end

    # build the prompt
    #
      prompt = formatted[ row ] 
      if current_category
        prompt.push("<- [#{ current_category }]")
      end
      prompt = prompt.join(' | ')

    # extract the category for this row
    #
      category = nil

      loop do
      # this reads badly... but provides help/context and help while #
      # editing...
      #
        puts '---'
        puts @categories.join("\n")
        puts
        puts header.join(' | ')

        line = Readline.readline("#{ prompt } >> ").to_s.strip

        case
          when line.empty?
            category = row['CATEGORY'] || current_category

          else
            category = line.strip
            current_category = category
        end

        break unless category.to_s.strip.empty?
      end

    # mark it and recall on top of our default set for subsequent readline
    # completions
    #
      row['CATEGORY'] = category
      puts formatted[ row ].join(' | ')
      @categories.push(category) unless @categories.include?(category)
    end
  end
}

````

ref: https://gist.github.com/anonymous/5079932

