require 'time'

class OldStrategy
  def initialize(level = 3)
    @level = level
  end

  def evaluate(userquakes, areapeer)
    result = { truly: false, reliability: 0, reliabilities_by_area: {} }

    return result if userquakes.size < 3

    3.upto(userquakes.size) { |take_count|
      picked_userquakes = userquakes.take(take_count)

      speed = picked_userquakes.size.to_f / (Time.parse(picked_userquakes.last["time"]) - Time.parse(picked_userquakes.first["time"]))
      rate  = picked_userquakes.size.to_f / areapeer["areas"].map { |area| area["peer"] }.sum

      area_rate = picked_userquakes.
        reject { |userquake| userquake["area"] / 100 == 9 }.
        group_by { |userquake| userquake["area"] }.
        select { |uq_area, area_userquakes| areapeer["areas"].map { |area| area["id"] }.include?(uq_area) }.
        map { |uq_area, area_userquakes| area_userquakes.size.to_f / areapeer["areas"].find { |area| area["id"] == uq_area }["peer"] }.max || 0

      region_rate = picked_userquakes.
        reject { |userquake| userquake["area"] / 100 == 9 }.
        group_by { |userquake| userquake["area"] / 100 }.
        map { |uq_region, region_userquakes| region_userquakes.size.to_f / picked_userquakes.size }.max || 0

      factor = [0.875, 1.0, 1.2, 1.4][@level - 1]

      if speed >= 0.25 * factor && area_rate >= 0.05 * factor
        result[:truly] = true
      end

      if speed >= 0.15 * factor && area_rate >= 0.3 * factor
        result[:truly] = true
      end

      if rate >= 0.01 * factor && area_rate >= 0.035 * factor
        result[:truly] = true
      end

      if rate >= 0.006 * factor && area_rate >= 0.04 * factor && region_rate >= [1 * factor, 1.0].min
        result[:truly] = true
      end

      if speed >= 0.18 * factor && area_rate >= 0.04 * factor && region_rate >= [1 * factor, 1.0].min
        result[:truly] = true
      end

      result[:appendix] = {
        speed: speed,
        rate: rate,
        area_rate: area_rate,
        region_rate: region_rate
      }
    }

    result
  end
end
