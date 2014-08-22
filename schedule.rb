require 'json'
require 'nokogiri'
require 'open-uri'

class Schedule

  attr_accessor :year, :weeks

  def initialize
    @teams = {
        'NY Giants' => 'Giants',
        'NY Jets' => 'Jets',
        'Baltimore' => 'Ravens',
        'Denver' => 'Broncos',
        'New England' => 'Patriots',
        'Buffalo' => 'Bills',
        'Cincinnati' => 'Bengals',
        'Chicago' => 'Bears',
        'Miami' => 'Dolphins',
        'Cleveland' => 'Browns',
        'Atlanta' => 'Falcons',
        'New Orleans' => 'Saints',
        'Tampa Bay' => 'Buccaneers',
        'Tennessee' => 'Titans',
        'Pittsburgh' => 'Steelers',
        'Minnesota' => 'Vikings',
        'Detroit' => 'Lions',
        'Oakland' => 'Raiders',
        'Indianapolis' => 'Colts',
        'Seattle' => 'Seahawks',
        'Carolina' => 'Panthers',
        'Kansas City' => 'Chiefs',
        'Jacksonville' => 'Jaguars',
        'Arizona' => 'Cardinals',
        'St. Louis' => 'Rams',
        'Green Bay' => 'Packers',
        'San Francisco' => '49ers',
        'Dallas' => 'Cowboys',
        'Philadelphia' => 'Eagles',
        'Washington' => 'Redskins',
        'Houston' => 'Texans',
        'San Diego' => 'Chargers'
    }

    @misses = []
  end

  def import_html(url, year)

    @year = year

    date = ''

    @weeks = (1..17).map do |week_id|
      page = Nokogiri::HTML(open(url + week_id.to_s))

      table = page.search('//table[@class="tablehead"]').first

      games = table.search('tr').map do |row|
        case row['class']
          when 'colhead'
            date = row.at('td[1]').text.strip
            nil
          when 'stathead'
            nil
          else
            first_td = row.at('td[1]')
            if first_td['colspan']
              nil
            else
              guest, home = first_td.text.strip.split(/ at /)

              guest = @teams.fetch(guest) { @misses << guest; guest }
              home = @teams.fetch(home) { @misses << home; home }

              starts = row.at('td[2]').text.strip

              {
                  :home => home,
                  :guest => guest,
                  :starts => convert_date(date, starts)
              }
            end
        end
      end

      {
          :position => week_id,
          :games => games.compact
      }

    end

  end

  def convert_date(date, starts)
    _, _, month, day = date.split(/[, ]/)

    time = starts.gsub(/ ([A|P]M)/, ':00 \1')
    "#{month.capitalize} #{day}, #{@year} #{time}"
  end

  def export
    puts @misses.uniq

    @season = {}

    @season[:year] = @year if @year
    @season[:weeks] = @weeks if @weeks

    JSON.generate(@season)
  end

end

if __FILE__ == $0
  schedule = Schedule.new
  schedule.import_html('http://espn.go.com/nfl/schedule/_/year/2014/seasontype/2/week/', 2014)
  puts schedule.export
end

