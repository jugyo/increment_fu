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
      if max_value = send(:"max_#{attribute}_value")
        self[attribute] = max_value if self[attribute] > max_value
      end
      self
    end

    define_method(:"increment_#{attribute}!") do |by = 1|
      send(:"increment_#{attribute}", by).update_attribute(attribute, self[attribute])
    end

    define_method(:"max_#{attribute}_value") do
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
      if min_value = send(:"min_#{attribute}_value")
        self[attribute] = min_value if self[attribute] < min_value
      end
      self
    end

    define_method(:"decrement_#{attribute}!") do |by = 1|
      send(:"decrement_#{attribute}", by).update_attribute(attribute, self[attribute])
    end

    define_method(:"min_#{attribute}_value") do
      if min
        if min.is_a?(Proc)
          min.call(self)
        else
          min
        end
      end
    end

    #
    # validation
    #

    validates_numericality_of attribute, :only_integer => true, :allow_nil => true

    validate do |record|
      next unless record[attribute]

      value = record[attribute]
      max_value = record.send(:"max_#{attribute}_value")
      min_value = record.send(:"min_#{attribute}_value")

      record.errors.add(attribute, "#{attribute} must be less than or equal to #{max_value}: #{value}") unless max_value.nil? || value <= max_value
      record.errors.add(attribute, "#{attribute} must be greater than or equal to #{min_value}: #{value}") unless min_value.nil? || value >= min_value
    end
  end
end

ActiveRecord::Base.send(:extend, IncrementFu)
