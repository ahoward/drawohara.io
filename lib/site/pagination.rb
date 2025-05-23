module Pagination
  def paginate(*args, page:nil, per:nil, size:nil, **kws)
    options = Map.for(args.last.is_a?(Hash) ? args.pop : {})

    options[:page] = page if page
    options[:per] = per if per
    options[:size] = size if size

    options.merge!(kws)

    page = Integer(args.shift || options[:page] || 1)
    per = Integer(args.shift || options[:per] || options[:size] || 10)

    page = [page.abs, 1].max
    per = [per.abs, 1].max

    offset = (page - 1) * per
    length = per

    slice = dup.slice(offset, length)
    slice.page = page
    slice.per = per
    slice.num_pages = (size.to_f / per).ceil
    slice
  end

  def page=(page)
    @page = page
  end

  def page(*_args)
    paginate unless @page
    @page
  end

  def current_page
    page
  end

  def per=(per)
    @per = per
  end

  def per
    paginate unless @per
    @per
  end

  def num_pages=(num_pages)
    @num_pages = num_pages
  end

  def num_pages
    paginate unless @num_pages
    @num_pages
  end

  def total_pages
    num_pages
  end
end
