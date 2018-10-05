module Chewy::Web
  module IndexUtils
    EXCLUDED_INDICES = [Chewy::Stash::Specification, Chewy::Stash::Journal]
    @@_index_classes = nil

    def self.index_classes
      @@_index_classes ||= (Chewy::Index.descendants - EXCLUDED_INDICES).uniq { |i| i.name }
    end

    def self.index_class_names
      index_classes.map(&:name)
    end

    def self.index_stats

    end
  end
end
