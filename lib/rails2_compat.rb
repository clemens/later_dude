unless ''.respond_to?(:html_safe)
  class String
    def html_safe
      self
    end
  end
end
