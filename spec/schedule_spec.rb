require 'spec_helper'

describe Schedule do
  context 'when empty schedule' do
    schedule = Schedule.new

    it 'export returns empty json' do
      expect(schedule.export(false)).to eq('{}')
    end
  end

  context 'when one week' do
    schedule = Schedule.new

    schedule.year = 2014
    schedule.weeks = [
        {
            position: 1,
            games: [
                {
                    home: 'home1',
                    guest: 'guest1',
                    starts: "Aug 17, 2013 1:16:05 PM"
                },
                {
                    home: 'home2',
                    guest: 'guest2',
                    starts: "Aug 17, 2013 2:16:05 PM"
                }
            ]
        }
    ]

    it 'export returns json with one week data in it' do
      expect(schedule.export(false)).to eq('{"year":2014,"weeks":[{"position":1,"games":[{"home":"home1","guest":"guest1","starts":"Aug 17, 2013 1:16:05 PM"},{"home":"home2","guest":"guest2","starts":"Aug 17, 2013 2:16:05 PM"}]}]}')
    end

  end

  context 'date conversion' do
    schedule = Schedule.new

    # first sunday in November is when EDT(-4) switched into EST(-5)
    # https://en.wikipedia.org/wiki/Eastern_Time_Zone

    it 'must correctly format EDT' do
      expect(schedule.convert_date('2018-09-09T17:00Z')).to eq('Sep 9, 2018 1:00:00 PM')
    end

    it 'must correctly format EST' do
      expect(schedule.convert_date('2018-11-29T17:00Z')).to eq('Nov 29, 2018 12:00:00 PM')
    end
  end
end