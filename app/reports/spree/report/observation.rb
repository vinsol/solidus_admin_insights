class Spree::Report::Observation

  def initialize
    set_defaults
  end

  class << self
    def observation_fields(records)
      case records
      when Hash
        build_from_hash(records)
      else
        build_from_list(records)
      end
    end

    def build_from_hash(records)
      build_from_list(records.keys)

      define_method :set_defaults do
        records.keys.each do |key|
          self.send("#{ key }=", records[key])
        end
      end
    end

    def build_from_list(records)
      attr_accessor *records

      define_method :populate do |result|
        records.each do |record|
          self.send("#{ record }=", result[record.to_s])
        end
      end

      define_method :set_defaults do
      end

      define_method :observations_to_h do
        records.inject({}) { |acc, record| acc[record] = self.send(record); acc }
      end
    end
  end

  def to_h
    observations_to_h
  end
end
