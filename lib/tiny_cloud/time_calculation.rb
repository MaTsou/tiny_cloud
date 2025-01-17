module TinyCloud
  module TimeCalculation
    SECONDS_PER_DAY = 86400

    def now
      Time.now
    end

    # args is { days: n }
    # for now only days is supported
    def convert_in_seconds( hash )
      hash.reduce( 0 ) do |seconds, delay|
        case [delay].to_h
        in days:
          seconds += SECONDS_PER_DAY * days
        else
          seconds
        end
      end
    end
  end
end
