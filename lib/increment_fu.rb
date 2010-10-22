module IncrementFu
  def increment_fu(attribute, options = {})
    min = options[:min]
    max = options[:max]

    #
    # increment
    #

    define_method(:"increment_#{attribute}") do |by = 1|
      self[attribute] ||= 0
      self[attribute] += by
      if max_value = send(:"max_#{attribute}")
        self[attribute] = max_value if self[attribute] > max_value
      end
      self
    end

    define_method(:"increment_#{attribute}!") do |by = 1|
      send(:"increment_#{attribute}", by).update_attribute(attribute, self[attribute])
    end

    define_method(:"max_#{attribute}") do
      if max
        if max.is_a?(Proc)
          max.call(self)
        else
          max
        end
      end
    end

    #
    # decrement
    #

    define_method(:"decrement_#{attribute}") do |by = 1|
      self[attribute] ||= 0
      self[attribute] -= by
      if min_value = send(:"min_#{attribute}")
        self[attribute] = min_value if self[attribute] < min_value
      end
      self
    end

    define_method(:"decrement_#{attribute}!") do |by = 1|
      send(:"decrement_#{attribute}", by).update_attribute(attribute, self[attribute])
    end

    define_method(:"min_#{attribute}") do
      if min
        if min.is_a?(Proc)
          min.call(self)
        else
          min
        end
      end
    end
  end
end

ActiveRecord::Base.send(:extend, IncrementFu)
