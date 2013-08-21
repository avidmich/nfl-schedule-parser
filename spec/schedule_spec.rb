require 'spec_helper'

describe Schedule do

  context 'when empty schedule' do
    schedule = Schedule.new

    it 'export returns empty json' do
      schedule.export.should == '{}'
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
      schedule.export.should == '{"year":2014,"weeks":[{"position":1,"games":[{"home":"home1","guest":"guest1","starts":"Aug 17, 2013 1:16:05 PM"},{"home":"home2","guest":"guest2","starts":"Aug 17, 2013 2:16:05 PM"}]}]}'
    end

  end
end