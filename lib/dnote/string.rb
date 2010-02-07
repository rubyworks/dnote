class Xacto

  # Extensions for String class.
  # These methods are taken directly from Ruby Facets.
  #
  module String

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

    def margin(n=0)
      #d = /\A.*\n\s*(.)/.match( self )[1]
      #d = /\A\s*(.)/.match( self)[1] unless d
      d = ((/\A.*\n\s*(.)/.match(self)) ||
          (/\A\s*(.)/.match(self)))[1]
      return '' unless d
      if n == 0
        gsub(/\n\s*\Z/,'').gsub(/^\s*[#{d}]/, '')
      else
        gsub(/\n\s*\Z/,'').gsub(/^\s*[#{d}]/, ' ' * n)
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
        gsub(/^ {0,#{-n}}/, "")
      end
    end

  end

  class ::String #:nodoc:
    include Xacto::String
  end

end

