class PolyArray
    @array = []

    @index_proc_by_type = {}
    @group_proc_by_type = {}

    @index_hash_by_type = {}
    @group_hash_by_type = {}

    def initialize(array)
        @array = array

        @index_hash_by_type = {}
        @group_hash_by_type = {}
        @index_proc_by_type = {}
        @group_proc_by_type = {}
    end

    def index_on(&index_block)
        klass = validate!(&index_block)

        @index_proc_by_type[klass] = index_block

        self.regenerate
    end

    def group_on(&group_block)
        klass = validate!(&group_block)

        @group_proc_by_type[klass] = group_block

        self.regenerate
    end

    def [](value)
        if @index_hash_by_type[value.class].nil? &&
                  @group_hash_by_type[value.class].nil?
            raise KeyError.new("No index/group on #{value.class}")
        end

        unless @index_hash_by_type[value.class].nil?
            return @index_hash_by_type[value.class][value]
        end

        unless @group_hash_by_type[value.class].nil?
            return @group_hash_by_type[value.class][value]
        end
    end

    private

    def regenerate(force: false)
        has_indexes_changed =
            force ||
                @index_hash_by_type.keys.length != @index_proc_by_type.keys.length
        has_groups_changed =
            force ||
                @group_hash_by_type.keys.length != @group_proc_by_type.keys.length

        puts has_indexes_changed
        puts has_groups_changed

        return self unless has_indexes_changed || has_groups_changed

        @index_hash_by_type = {}
        @group_hash_by_type = {}

        @array.each do |item|
            klass = item.class

            if has_indexes_changed && !@index_proc_by_type[klass].nil?
                index_key = @index_proc_by_type[klass].call(item)

                @index_hash_by_type[klass] ||= {}
                @index_hash_by_type[klass][index_key] = item
            end

            if has_groups_changed && !@group_proc_by_type[klass].nil?
                group_key = @group_proc_by_type[klass].call(item)

                @group_hash_by_type[klass] ||= {}
                @group_hash_by_type[klass][group_key] ||= []
                @group_hash_by_type[klass][group_key] << item
            end
        end

        self
    end

    def validate!(&block)
        classes = @array.map { |item| yield(item).class }.uniq

        raise "Multiple field types given for index" if classes.length != 1

        klass = classes.first

        unless @index_hash_by_type[klass].nil? && @group_hash_by_type[klass].nil?
            raise "Already indexed on type"
        end

        klass
    end
end

module Enumerable
    def to_poly
        PolyArray.new(self)
    end
end
