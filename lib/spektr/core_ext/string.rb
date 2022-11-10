class String
  def blank?
    nil? || self == ""
  end

  def underscore
    camel_cased_word = self
    return camel_cased_word.to_s unless /[A-Z-]|::/.match?(camel_cased_word)
    word = camel_cased_word.to_s.gsub("::", "/")
    word.gsub!(/(?:(?<=([A-Za-z\d]))|\b)((?=a))(?=\b|[^a-z])/) { "#{$1 && '_' }#{$2.downcase}" }
    word.gsub!(/([A-Z]+)(?=[A-Z][a-z])|([a-z\d])(?=[A-Z])/) { ($1 || $2) << "_" }
    word.tr!("-", "_")
    word.downcase!
    word
  end
end
