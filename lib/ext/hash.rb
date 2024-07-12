require_relative "../field_expression"

class Hash
    # def interp2(value)
    #     t0 = self.keys.first
    #     x0 = self.values.first

    #     t1 = self.keys.last
    #     x1 = self.values.last

    #     (x0 + (x1 - x0) * (value - t0) / (t1 - t0)).collect.push_zero
    # end

    def interp(key)
        self
            .reduce(FieldExpression.new(nil, factor: 0)) do |acc, (k, v)|
                v.field_expression * k_product(key, k) + acc
            end
            .collect
            .push_zero
    end

    private

    def k_product(param, key)
        self.except(key).reduce(1) { |acc, (k, _)| acc * (param - k) / (key - k) }
    end
end
