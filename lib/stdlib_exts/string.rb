class String
  
  def without_trailing_slash
    gsub(/\/$/, '')
  end
  
  def enclose_in_single_quotes
    return "''" if nil? || empty?
    split(/'/, -1).map{|e| "'#{e}'"}.join("\\'")
  end
  
end