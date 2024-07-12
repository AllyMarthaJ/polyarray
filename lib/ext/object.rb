require_relative "../field_expression"

class Object
    def field_expression
        self.is_a?(FieldExpression) ? self : FieldExpression.new(self)
    end

    def zero?
        self == 0 || (self.respond_to?(:empty?) && self.empty?)
    end
end
