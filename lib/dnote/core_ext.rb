# frozen_string_literal: true

module DNote
  # Extensions for String class.
  # These methods are taken directly from Ruby Facets.
  #
  module StringExt
    # Indent left or right by num spaces.
    # (This used to be called #tab and aliased as #indent.)
    #
    #  CREDIT: Gavin Sinclair
    #  CREDIT: Trans

    def indent(num)
      if num >= 0
        gsub(/^/, " " * num)
      else
        gsub(/^ {0,#{-num}}/, "")
      end
    end

    def tabset(num)
      i = lines.map do |line|
        line.strip.empty? ? nil : line.index(/\S/)
      end
      x = i.compact.min
      t = num - x.to_i
      t = 0 if t < 0
      indent(t)
    end
  end
end

String.class_eval do
  include DNote::StringExt
end
