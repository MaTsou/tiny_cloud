# frozen_string_literal: true

module TinyCloud
  # time calculation module
  module TimeCalculation
    SECONDS_PER_HOUR = 3600
    SECONDS_PER_DAY = 24 * SECONDS_PER_HOUR
    SECONDS_PER_WEEK = 7 * SECONDS_PER_DAY
    SECONDS_PER_YEAR = 365.25 * SECONDS_PER_DAY

    def now
      Time.now
    end

    def tomorrow
      now + convert_in_seconds({ days: 1 })
    end

    # args is { year: y, weeks: w, days: d, hours: h }
    def convert_in_seconds(hash)
      hash.reduce(0) do |seconds, delay|
        seconds + to_seconds([delay].to_h)
      end
    end

    private

    def to_seconds(delay)
      case delay
      in years:
        SECONDS_PER_YEAR * years
      in weeks:
        SECONDS_PER_WEEK * weeks
      in days:
        SECONDS_PER_DAY * days
      in hours:
        SECONDS_PER_HOUR * hours
      else 0 end
    end
  end
end
