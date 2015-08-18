require 'json'
require 'nokogiri'
require 'open-uri'

class Schedule

  attr_accessor :year, :weeks

  def initialize
    @teams = {
        'NYG' => 'Giants',
        'NYJ' => 'Jets',
        'BAL' => 'Ravens',
        'DEN' => 'Broncos',
        'NE' => 'Patriots',
        'BUF' => 'Bills',
        'CIN' => 'Bengals',
        'CHI' => 'Bears',
        'MIA' => 'Dolphins',
        'CLE' => 'Browns',
        'ATL' => 'Falcons',
        'NO' => 'Saints',
        'TB' => 'Buccaneers',
        'TEN' => 'Titans',
        'PIT' => 'Steelers',
        'MIN' => 'Vikings',
        'DET' => 'Lions',
        'OAK' => 'Raiders',
        'IND' => 'Colts',
        'SEA' => 'Seahawks',
        'CAR' => 'Panthers',
        'KC' => 'Chiefs',
        'JAX' => 'Jaguars',
        'ARI' => 'Cardinals',
        'STL' => 'Rams',
        'GB' => 'Packers',
        'SF' => '49ers',
        'DAL' => 'Cowboys',
        'PHI' => 'Eagles',
        'WSH' => 'Redskins',
        'HOU' => 'Texans',
        'SD' => 'Chargers'
    }

    @misses = []
  end

  def import_html(url, year)

    @year = year

    @weeks = (1..17).map do |week_id|
      page = Nokogiri::HTML(open(url + week_id.to_s))

      schedule_div = page.search('//div[@id="sched-container"]').first

      games = schedule_div.search('table/tbody/tr').map do |row|
        guest = row.at('td[1]/a/abbr').text.strip
        home = row.at('td[2]/a/abbr').text.strip
        guest = @teams.fetch(guest) { @misses << guest; guest }
        home = @teams.fetch(home) { @misses << home; home }

        starts = row.at('td[3]/@data-date')

        {
            :home => home,
            :guest => guest,
            :starts => convert_date(starts)
        }
      end

      {
          :position => week_id,
          :games => games.compact
      }

    end

  end

  def convert_date(date)
    Time.strptime(date, '%FT%R%:z').getlocal.strftime('%b %-d, %Y %-I:%M:%S %p')
  end

  def export
    @season = {}

    @season[:year] = @year if @year
    @season[:weeks] = @weeks if @weeks

    JSON.generate(@season)
  end

end

if __FILE__ == $0
  schedule = Schedule.new
  schedule.import_html('http://espn.go.com/nfl/schedule/_/year/2015/seasontype/2/week/', 2015)
  puts schedule.export
end

