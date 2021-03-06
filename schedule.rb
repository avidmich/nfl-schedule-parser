require 'json'
require 'nokogiri'
require 'open-uri'
require 'tzinfo'

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
        'LAR' => 'Rams',
        'GB' => 'Packers',
        'SF' => '49ers',
        'DAL' => 'Cowboys',
        'PHI' => 'Eagles',
        'WSH' => 'Redskins',
        'HOU' => 'Texans',
        'LAC' => 'Chargers'
    }

    @misses = []
    
    @timezone = TZInfo::Timezone.get('America/New_York')
  end

  def import_html(url, year)

    @year = year

    @weeks = (1..17).map do |week_id|
      page = Nokogiri::HTML(open(url + week_id.to_s))

      schedule_div = page.search('//div[@id="sched-container"]').first

      games = schedule_div.search('table/tbody/tr').map do |row|
        guest = team_name(row, 1)
        home = team_name(row, 2)
        guest = @teams.fetch(guest) { @misses << guest; guest }
        home = @teams.fetch(home) { @misses << home; home }

        starts = row.at('td[3]/@data-date')

        unless starts
          puts "NOTE: no time for #{guest} @ #{home} during week #{week_id}"  
        end

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
    if date
      @timezone.utc_to_local(Time.strptime(date, '%FT%R%:z')).strftime('%b %-d, %Y %-I:%M:%S %p')
    end
  end

  def export(pretty = true)
    @season = {}

    @season[:year] = @year if @year
    @season[:weeks] = @weeks if @weeks

    if pretty 
      JSON.pretty_generate(@season)
    else
      JSON.generate(@season)
    end
  end

  private

  def team_name(row, index)
    node = row.at("td[#{index}]//a/abbr")
    node.text.strip
  end

end

if __FILE__ == $0
  schedule = Schedule.new
  schedule.import_html('http://www.espn.com/nfl/schedule/_/seasontype/2/week/', 2019)
  puts schedule.export
end

