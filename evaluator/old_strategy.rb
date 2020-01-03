class OldStrategy
  def evaluate(userquakes, areapeer)
    @result = { truly: false, reliability: 0, reliabilities_by_area: {} }

    return @result if userquakes.size < 3

    speed = userquakes.size.to_f / (Time.parse(userquakes.last["time"]) - Time.parse(userquakes.first["time"]))
    rate  = userquakes.size.to_f / areapeer["areas"].map { |area| area["peer"] }.sum

    area_rate = userquakes.
      reject { |userquake| userquake["area"] / 100 == 9 }.
      group_by { |userquake| userquake["area"] }.
      select { |uq_area, area_userquakes| areapeer["areas"].map { |area| area["id"] }.include?(uq_area) }.
      map { |uq_area, area_userquakes| area_userquakes.size.to_f / areapeer["areas"].find { |area| area["id"] == uq_area }["peer"] }.max || 0

    region_rate = userquakes.
      reject { |userquake| userquake["area"] / 100 == 9 }.
      group_by { |userquake| userquake["area"] / 100 }.
      map { |uq_region, region_userquakes| region_userquakes.size.to_f / userquakes.size }.max || 0

    [userquakes.size, speed, rate, area_rate, region_rate]
  end
end
