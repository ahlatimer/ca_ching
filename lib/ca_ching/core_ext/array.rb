class Array
  attr_accessor :from_cache
  
  def from_cache?
    @from_cache ||= false
  end
end