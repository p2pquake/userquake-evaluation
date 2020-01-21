require 'time'

class OldStrategy
  def initialize(level = 3)
    @level = level
  end

  def evaluate(userquakes, areapeer)
    result = { truly: false, reliability: 0, reliabilities_by_area: {} }
    return result if userquakes.size < 3

    result.merge!(judge_truly(userquakes, areapeer))
    result.merge!(calc_reliability(userquakes, areapeer))

    result
  end

  private

  def judge_truly(userquakes, areapeer)
    result = {}

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

      result[:debug] = [] unless result[:debug]
      result[:debug] << result[:appendix]
    }

    result
  end

  def calc_reliability(userquakes, areapeer)
    result = { percent_by_area: {} }
    peer_by_area = areapeer["areas"].map { |area| [area["id"], area["peer"]] }.to_h
    peer_by_pref = areapeer["areas"].map { |area| [area["id"] / 10, area["peer"]] }.to_h
    peer_by_region = areapeer["areas"].map { |area| [area["id"] / 100, area["peer"]] }.to_h

    3.upto(userquakes.size) { |take_count|
      picked_userquakes = userquakes.take(take_count)

      # 各種パラメタ計算
      count_by_area = picked_userquakes.group_by { |userquake| userquake["area"] }.map { |k, v| [k, v.size] }.to_h
      count_by_pref = picked_userquakes.group_by { |userquake| userquake["area"] / 10 }.map { |k, v| [k, v.size] }.to_h
      count_by_region = picked_userquakes.group_by { |userquake| userquake["area"] / 100 }.map { |k, v| [k, v.size] }.to_h

      count_by_area.each { |area, count|
        next if !peer_by_area[area]

        percent = count.to_f / peer_by_area[area] * 100
        if count / peer_by_area.values.sum.to_f < 0.01
          percent *= count / peer_by_area.values.sum.to_f * 100
        else
          percent *= 1.2
        end
        percent *= count_by_pref[area / 10].to_f / peer_by_pref[area / 10] * 5 + 1
        percent *= count_by_region[area / 100].to_f / peer_by_region[area / 100] * 5 + 1
        percent = [[0, percent].max, 100].min

        result[:percent_by_area][area] = [result[:percent_by_area][area] || 0, percent].max
      }

      result.merge!({ count_by_area: count_by_area, count_by_pref: count_by_pref, count_by_region: count_by_region })
    }
    result
  end
end
