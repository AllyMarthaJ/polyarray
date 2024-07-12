require_relative "../field_expression"

class Float
    unless @defined_mult
        alias_method :old_mult, :*
        @defined_mult = true
    end

    def *(other)
        # a * b = b * a
        other.is_a?(FieldExpression) ? other * self : old_mult(other)
    end
end
