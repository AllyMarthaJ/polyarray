# Basically a linked list with field operations.
# lols
class FieldExpression
    attr_reader :value, :factor, :next_value

    def initialize(value, factor: 1, next_value: nil)
        @value = value
        @factor = factor
        @next_value = next_value
    end

    def +(other)
        if other.is_a?(FieldExpression)
            if other.value == @value
                FieldExpression.new(
                    @value,
                    factor: @factor + other.factor,
                    next_value: @next_value,
                )
            else
                FieldExpression.new(
                    @value,
                    factor: @factor,
                    next_value: (@next_value.nil? ? other : @next_value + other),
                )
            end
        else
            raise TypeError.new("Cannot add FieldExpression to #{other.class}")
        end
    end

    def *(other)
        if other.is_a?(FieldExpression) && @value.respond_to?(:*)
            #TODO
        elsif other.is_a?(Numeric)
            FieldExpression.new(
                @value,
                factor: @factor * other,
                next_value: @next_value ? @next_value * other : nil,
            )
        else
            raise TypeError.new("Cannot multiply FieldExpression by #{other.class}")
        end
    end

    def -@
        self * -1
    end

    def -(other)
        self + -other
    end

    def /(other)
        if other.is_a?(FieldExpression) && @value.respond_to?(:/)
            #TODO
        elsif other.is_a?(Numeric)
            self * (1 / other)
        end
    end

    def push_zero
        if @factor.zero?
            @next_value&.push_zero
        else
            FieldExpression.new(
                self.value,
                factor: @factor,
                next_value: @next_value&.push_zero,
            )
        end
    end

    def collect
        # TODO: Memoise already-found values.

        # Recurse down the proceeding terms and attempt
        # to add self to them.
        parent = self

        # Look at the successor of the current link.
        while (successor = parent.instance_variable_get(:@next_value)) != nil
            # Is it fundamentally compatible with ourselves?
            if @value == successor.value
                # Yup, so let's mutate the successor to include ourselves
                # in the chain.
                successor += self
                parent.instance_variable_set(:@next_value, successor)

                # Rather subtracting ourselves off and running push_zero
                # we can simply return the next value and do the same thing
                # we did here.
                # This does make collecting terms quadratic time (and really
                # bad quadratic time: this exists on the heap and isn't even
                # contiguous in memory).
                return @next_value.collect
            end
            parent = successor
        end

        self
    end

    def to_s
        raise "Can't combine #{@value.class}" unless @value.respond_to?(:combinate)

        # of type @value.class; e.g. get_factored: T |-> T.
        factored_value =
            (
                if @value.respond_to?(:get_factored)
                    @value.get_factored(@factor)
                else
                    @value.to_s
                end
            )

        return factored_value if @next_value.nil?

        factored_value.combinate(@next_value.to_s)
    end
end
