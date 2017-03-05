module Enumerable
  # Taken from Ruby Facets.
  def group_by #:yield:
    r = Hash.new
    each { |e| (r[yield(e)] ||= []) << e }
    r
  end unless method_defined?(:group_by)
end

module DNote
  # Extensions for String class.
  # These methods are taken directly from Ruby Facets.
  #
  module StringExt
    # Provides a margin controlled string.
    #
    #   x = %Q{
    #         | This
    #         |   is
    #         |     margin controlled!
    #         }.margin
    #
    #
    #   NOTE: This may still need a bit of tweaking.
    #
    #  CREDIT: Trans

    def margin(n = 0)
      d = (/\A.*\n\s*(.)/.match(self) ||
          /\A\s*(.)/.match(self))[1]
      return '' unless d
      if n == 0
        gsub(/\n\s*\Z/, '').gsub(/^\s*[#{d}]/, '')
      else
        gsub(/\n\s*\Z/, '').gsub(/^\s*[#{d}]/, ' ' * n)
      end
    end

    # Preserves relative tabbing.
    # The first non-empty line ends up with n spaces before nonspace.
    #
    #  CREDIT: Gavin Sinclair

    def tabto(n)
      if self =~ /^( *)\S/
        indent(n - $1.length)
      else
        self
      end
    end

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

    #
    #
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

  ::String.class_eval do
    include DNote::StringExt
  end
end
