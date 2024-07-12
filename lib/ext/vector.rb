require "matrix"

class Vector
    def combinate(other)
        other.nil? ? self : self + other
    end

    def scale(factor)
        factor * self
    end
end
