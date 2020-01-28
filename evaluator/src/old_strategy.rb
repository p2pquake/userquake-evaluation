require 'time'

class OldStrategy
  ALLOW_X_RANGE = 35
  ALLOW_Y_RANGE = 45
  AREA_POSITIONS = {
    10 => [459, 88],
    15 => [426, 120],
    20 => [398, 118],
    25 => [439, 88],
    30 => [480, 79],
    35 => [504, 74],
    40 => [476, 55],
    45 => [480, 21],
    50 => [530, 68],
    55 => [444, 101],
    60 => [503, 110],
    65 => [524, 93],
    70 => [557, 88],
    75 => [576, 80],
    100 => [421, 163],
    105 => [444, 172],
    106 => [444, 140],
    110 => [458, 197],
    111 => [456, 216],
    115 => [438, 202],
    120 => [430, 229],
    125 => [420, 245],
    130 => [409, 193],
    135 => [423, 182],
    140 => [396, 223],
    141 => [411, 223],
    142 => [407, 236],
    143 => [396, 246],
    150 => [411, 266],
    151 => [427, 276],
    152 => [389, 267],
    200 => [412, 296],
    205 => [399, 308],
    210 => [388, 283],
    215 => [391, 297],
    220 => [357, 285],
    225 => [354, 298],
    230 => [375, 305],
    231 => [384, 312],
    232 => [357, 308],
    240 => [409, 323],
    241 => [396, 320],
    242 => [391, 336],
    250 => [373, 318],
    255 => [374, 359],
    260 => [387, 394],
    265 => [427, 435],
    270 => [378, 329],
    275 => [364, 325],
    300 => [332, 270],
    301 => [357, 268],
    302 => [378, 250],
    305 => [332, 227],
    310 => [315, 281],
    315 => [299, 283],
    320 => [297, 256],
    325 => [283, 284],
    330 => [274, 300],
    335 => [258, 311],
    340 => [351, 319],
    345 => [339, 312],
    350 => [332, 284],
    351 => [333, 298],
    355 => [321, 312],
    400 => [303, 297],
    405 => [287, 313],
    410 => [355, 344],
    411 => [349, 330],
    415 => [332, 332],
    416 => [320, 342],
    420 => [303, 344],
    425 => [294, 328],
    430 => [270, 341],
    435 => [272, 356],
    440 => [268, 320],
    445 => [264, 331],
    450 => [242, 312],
    455 => [249, 327],
    460 => [246, 337],
    465 => [244, 346],
    470 => [225, 311],
    475 => [227, 328],
    480 => [253, 356],
    490 => [235, 359],
    495 => [247, 375],
    500 => [209, 308],
    505 => [189, 307],
    510 => [165, 311],
    514 => [163, 276],
    515 => [140, 320],
    520 => [193, 319],
    525 => [190, 333],
    530 => [165, 324],
    535 => [161, 337],
    540 => [116, 337],
    541 => [130, 344],
    545 => [103, 346],
    550 => [200, 357],
    555 => [210, 365],
    560 => [196, 347],
    570 => [173, 355],
    575 => [154, 359],
    576 => [145, 372],
    580 => [196, 375],
    581 => [177, 367],
    582 => [158, 384],
    600 => [77, 354],
    601 => [97, 355],
    602 => [90, 364],
    605 => [85, 374],
    610 => [65, 363],
    615 => [72, 374],
    620 => [52, 370],
    625 => [63, 385],
    630 => [59, 336],
    635 => [21, 369],
    640 => [99, 388],
    641 => [87, 389],
    645 => [91, 405],
    646 => [74, 399],
    650 => [114, 363],
    651 => [117, 375],
    655 => [100, 376],
    656 => [123, 385],
    660 => [111, 408],
    661 => [105, 398],
    665 => [106, 423],
    666 => [97, 414],
    670 => [75, 416],
    675 => [89, 434],
    680 => [26, 427],
    685 => [155, 421],
    700 => [313, 385],
    701 => [310, 411],
    702 => [276, 404],
    705 => [237, 423],
    706 => [272, 437],
    710 => [324, 426],
  }

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
    result = { percent_by_area: {}, reliabilities_by_area: {} }
    peer_by_area = areapeer["areas"].map { |area| [area["id"], area["peer"]] }.to_h
    peer_by_pref = areapeer["areas"].map { |area| [area["id"] / 10, area["peer"]] }.to_h
    peer_by_region = areapeer["areas"].map { |area| [area["id"] / 100, area["peer"]] }.to_h

    userquakes.take(2).each { |userquake| result[:reliabilities_by_area][userquake["area"]] = 1 }

    # 表示判定
    3.upto(userquakes.size) { |take_count|
      picked_userquakes = userquakes.take(take_count)

      # 座標による
      result[:reliabilities_by_area].keys.map { |area| AREA_POSITIONS[area] }.compact.yield_self { |positions|
        [
          [positions.map(&:first).min, positions.map(&:first).max],
          [positions.map(&:last).min,  positions.map(&:last).max]
        ]
      }.tap { |positions|
        area = picked_userquakes.last["area"]
        position = AREA_POSITIONS[area]

        if position &&
            position[0] >= positions[0][0] - ALLOW_X_RANGE && position[0] <= positions[0][1] + ALLOW_X_RANGE &&
            position[1] >= positions[1][0] - ALLOW_Y_RANGE && position[1] <= positions[1][1] + ALLOW_Y_RANGE
          result[:reliabilities_by_area][area] = 1
        end
      }

      # 発信数による
      count_by_area = picked_userquakes.group_by { |userquake| userquake["area"] }.map { |k, v| [k, v.size] }.to_h.select { |area, count| peer_by_area[area] }
      count_by_area.each { |area, count|
        if !result[:reliabilities_by_area][area] &&
            (
              (count_by_area[area] >= 3 && count_by_area[area].to_f / peer_by_area[area] >= 0.5) ||
              (count_by_area[area] >= 5 && count_by_area[area].to_f / peer_by_area[area] >= 0.1)
            )
          result[:reliabilities_by_area][area] = 1
        end
      }
    }

    3.upto(userquakes.size) { |take_count|
      picked_userquakes = userquakes.take(take_count)

      # 各種パラメタ計算
      count_by_area = picked_userquakes.group_by { |userquake| userquake["area"] }.map { |k, v| [k, v.size] }.to_h
      count_by_pref = picked_userquakes.group_by { |userquake| userquake["area"] / 10 }.map { |k, v| [k, v.size] }.to_h
      count_by_region = picked_userquakes.group_by { |userquake| userquake["area"] / 100 }.map { |k, v| [k, v.size] }.to_h

      count_by_area.each { |area, count|
        next if !peer_by_area[area]

        # 信頼度
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

    result[:reliabilities_by_area] = result[:reliabilities_by_area].map { |area, flag|
      [
        area,
        if flag != 1
          "F"
        else
          ["E", "D", "C", "B", "A", "A"][((result[:percent_by_area][area] || 0) / 20).to_i]
        end
      ]
    }.to_h

    result
  end
end
