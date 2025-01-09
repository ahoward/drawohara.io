module Util
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

  extend Util
end
