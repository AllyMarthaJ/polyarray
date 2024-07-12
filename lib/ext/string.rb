class String
    def combinate(other)
        other.nil? ? self : self + other
    end

    def get_factored(factor)
        len = (self.length * factor).abs.round

        return "" if len == 0

        if factor < 0
            # Take len characters from the start
            self[0..len - 1] || ""
        else
            # Take len characters from the end
            self[-len..-1] || ""
        end
    end
end
