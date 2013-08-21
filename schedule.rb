require 'json'
require 'nokogiri'
require 'open-uri'

class Schedule

  attr_accessor :year, :weeks

  def import_html(url)

    @year = url.split(/\//).last

    page = Nokogiri::HTML(open(url))

    weekCount = 0
    date = ''

    @weeks = page.search('//table[@class="tablehead"]').map do |table|
      games = table.search('tr').map do |row|
        value = row.at('td[1]').text.strip rescue 'n/a'
        type = row['class']
        case type
          when 'colhead'
            date = value
            nil
          when 'stathead'
            nil
          else
            guest, home = value.split(/ at /)

            starts = row.at('td[2]').text.strip rescue 'n/a'

            {
                :home => home,
                :guest => guest,
                :starts => date + ', ' + starts
            }
        end
      end
      weekCount += 1
      {
          :position => weekCount,
          :games => games.compact
      }
    end
  end

  def export
    @season = {}

    @season[:year] = @year if @year
    @season[:weeks] = @weeks if @weeks

    JSON.generate(@season)
  end

end

if __FILE__ == $0
  url = 'http://espn.go.com/nfl/schedule/_/year/2013'
  schedule = Schedule.new
  schedule.import_html(url)
  puts schedule.export
end

