require "./src/old_strategy.rb"

RSpec.describe OldStrategy do
  let(:areapeer) {
    { "areas" => [
      { "id" => 101, "peer" => 100 },
      { "id" => 102, "peer" => 200 },
      { "id" => 201, "peer" => 300 },
      { "id" => 202, "peer" => 10000 },
    ] }
  }
  context "count < 3" do
    let(:userquakes) { [
      { "time" => "2020/01/05 18:00:00.050", "area" => 101 },
      { "time" => "2020/01/05 18:00:00.100", "area" => 101 },
    ] }

    it "not truly" do
      result = OldStrategy.new(2).evaluate(userquakes, areapeer)
      expect(result[:truly]).to eq(false)
    end
  end

  context "count >= 3" do
    # iType: 1
    context "speed >= 0.25" do
      context "area_rate >= 0.05" do
        let(:userquakes) { [
          { "time" => "2020/01/05 18:00:00.000", "area" => 101 },
          { "time" => "2020/01/05 18:00:20.000", "area" => 201 },
          { "time" => "2020/01/05 18:00:24.000", "area" => 101 },
          { "time" => "2020/01/05 18:00:24.000", "area" => 101 },
          { "time" => "2020/01/05 18:00:24.000", "area" => 101 },
          { "time" => "2020/01/05 18:00:24.000", "area" => 101 },
        ] }

        context "level 2" do
          it "truly" do
            result = OldStrategy.new(2).evaluate(userquakes, areapeer)
            expect(result[:truly]).to eq(true)
          end
        end
      end

      context "area_rate < 0.05" do
        let(:userquakes) { [
          { "time" => "2020/01/05 18:00:00.000", "area" => 101 },
          { "time" => "2020/01/05 18:00:18.000", "area" => 201 },
          { "time" => "2020/01/05 18:00:20.000", "area" => 101 },
          { "time" => "2020/01/05 18:00:20.000", "area" => 101 },
          { "time" => "2020/01/05 18:00:20.000", "area" => 101 },
        ] }

        context "level 1" do
          it "not truly" do
            result = OldStrategy.new(1).evaluate(userquakes, areapeer)
            expect(result[:truly]).to eq(false)
          end
        end
      end
    end

    # iType: 2
    context "speed >= 0.15" do
      context "area_rate >= 0.3" do
        let(:userquakes) {
          array = []
          array << { "time" => "2020/01/05 18:00:00.000", "area" => 101 }
          28.times { array << { "time" => "2020/01/05 18:03:19.000", "area" => 101 } }
          array << { "time" => "2020/01/05 18:03:20.000", "area" => 201 }
          array << { "time" => "2020/01/05 18:03:20.000", "area" => 101 }
          array
        }

        context "level 2" do
          it "truly" do
            result = OldStrategy.new(2).evaluate(userquakes, areapeer)
            expect(result[:truly]).to eq(true)
          end
        end

        context "level 3" do
          it "not truly" do
            result = OldStrategy.new(3).evaluate(userquakes, areapeer)
            expect(result[:truly]).to eq(false)
          end
        end
      end

      context "area_rate < 0.3" do
        let(:userquakes) {
          array = []
          array << { "time" => "2020/01/05 18:00:00.000", "area" => 101 }
          27.times { array << { "time" => "2020/01/05 18:03:19.000", "area" => 101 } }
          array << { "time" => "2020/01/05 18:03:20.000", "area" => 201 }
          array << { "time" => "2020/01/05 18:03:20.000", "area" => 101 }
          array
        }

        context "level 2" do
          it "not truly" do
            result = OldStrategy.new(2).evaluate(userquakes, areapeer)
            expect(result[:truly]).to eq(false)
          end
        end
      end
    end

    # iType: 3
    context "rate >= 0.01" do
      context "area_rate >= 0.035" do
        let(:userquakes) {
          array = []
          array << { "time" => "2020/01/05 18:00:00.000", "area" => 101 }
          94.times { array << { "time" => "2020/01/06 18:00:00.000", "area" => 202 } }
          11.times { array << { "time" => "2020/01/06 18:00:00.000", "area" => 201 } }
          array
        }

        context "level 2" do
          it "truly" do
            result = OldStrategy.new(2).evaluate(userquakes, areapeer)
            expect(result[:truly]).to eq(true)
          end
        end
      end

      context "area_rate < 0.035" do
        let(:userquakes) {
          array = []
          array << { "time" => "2020/01/05 18:00:00.000", "area" => 101 }
          94.times { array << { "time" => "2020/01/06 18:00:00.000", "area" => 202 } }
          10.times { array << { "time" => "2020/01/06 18:00:00.000", "area" => 201 } }
          array
        }

        context "level 2" do
          it "not truly" do
            result = OldStrategy.new(2).evaluate(userquakes, areapeer)
            expect(result[:truly]).to eq(false)
          end
        end
      end
    end

    # iType: 4
    context "rate >= 0.006 && region_area == 1" do
      context "area_rate >= 0.04" do
        let(:userquakes) {
          array = []
          array << { "time" => "2020/01/05 18:00:00.000", "area" => 201 }
          11.times { array << { "time" => "2020/01/06 18:00:00.000", "area" => 201 } }
          52.times { array << { "time" => "2020/01/06 18:00:00.000", "area" => 202 } }
          array
        }

        context "level 2" do
          it "truly" do
            result = OldStrategy.new(2).evaluate(userquakes, areapeer)
            expect(result[:truly]).to eq(true)
          end
        end
      end

      context "area_rate < 0.04" do
        let(:userquakes) {
          array = []
          array << { "time" => "2020/01/05 18:00:00.000", "area" => 201 }
          10.times { array << { "time" => "2020/01/06 18:00:00.000", "area" => 201 } }
          53.times { array << { "time" => "2020/01/06 18:00:00.000", "area" => 202 } }
          array
        }

        context "level 2" do
          it "not truly" do
            result = OldStrategy.new(2).evaluate(userquakes, areapeer)
            expect(result[:truly]).to eq(false)
          end
        end
      end
    end

    # iType: 5
    context "speed >= 0.18 && region_area == 1" do
      context "area_rate >= 0.04" do
        let(:userquakes) { [
          { "time" => "2020/01/05 18:00:00.000", "area" => 101 },
          { "time" => "2020/01/05 18:00:22.200", "area" => 101 },
          { "time" => "2020/01/05 18:00:22.200", "area" => 101 },
          { "time" => "2020/01/05 18:00:22.200", "area" => 101 },
        ] }

        context "level 2" do
          it "truly" do
            result = OldStrategy.new(2).evaluate(userquakes, areapeer)
            expect(result[:truly]).to eq(true)
          end
        end
      end

      context "area_rate < 0.04" do
        let(:userquakes) { [
          { "time" => "2020/01/05 18:00:00.000", "area" => 101 },
          { "time" => "2020/01/05 18:00:22.200", "area" => 101 },
          { "time" => "2020/01/05 18:00:22.200", "area" => 101 },
          { "time" => "2020/01/05 18:00:22.200", "area" => 102 },
        ] }

        context "level 2" do
          it "not truly" do
            result = OldStrategy.new(2).evaluate(userquakes, areapeer)
            expect(result[:truly]).to eq(false)
          end
        end
      end
    end
  end
end

