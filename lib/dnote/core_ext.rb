module Enumerable

  # Taken from Ruby Facets.
  def group_by #:yield:
    #h = k = e = nil
    r = Hash.new
    each{ |e| (r[yield(e)] ||= []) << e }
    r
  end unless method_defined?(:group_by)

end

