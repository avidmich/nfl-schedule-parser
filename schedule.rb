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

              starts = row.at('td[2]').text.strip

              {
                  :home => home,
                  :guest => guest,
                  :starts => convert_date(date, starts)
              }
            end
        end
      end
      weekCount += 1
      {
          :position => weekCount,
          :games => games.compact
      }
    end
  end

  def convert_date(date, starts)
    _, _, month, day = date.split(/[, ]/)

    month.capitalize + ' ' + day + ', 2013 ' + starts
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

