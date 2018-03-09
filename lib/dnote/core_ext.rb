module DNote
  # Extensions for String class.
  # These methods are taken directly from Ruby Facets.
  #
  module StringExt
    # Indent left or right by n spaces.
    # (This used to be called #tab and aliased as #indent.)
    #
    #  CREDIT: Gavin Sinclair
    #  CREDIT: Trans

    def indent(n)
      if n >= 0
        gsub(/^/, ' ' * n)
      else
        gsub(/^ {0,#{-n}}/, '')
      end
    end

    def tabset(n)
      i = lines.map do |line|
        line.strip.empty? ? nil : line.index(/\S/)
      end
      x = i.compact.min
      t = n - x.to_i
      t = 0 if t < 0
      indent(t)
    end
  end
end

String.class_eval do
  include DNote::StringExt
end
