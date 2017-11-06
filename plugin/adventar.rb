require 'net/http'
require 'nokogiri'

require_relative '../model/history'

class Adventar
  class << self
    def func(calid)
      res = get_rawdata(calid)
      return nil if res.nil?
      data = res[:data]

      entries = data['entries']
      {
        title: res[:title],
        desc: res[:desc],
        url: res[:url],
        entries: (entries.map do |e|
          old = History.find_old(e['id'])
          updated = old.nil? ? Time.now : old['updated']
          History.update e['id'] if old.nil? && !e['url'].nil? && !e['url'].empty?

          {
            date: e['date'] || Time.now,
            title: e['title'] || '',
            url: e['url'] || '',
            updated: updated || Time.now,
          }
        end.reject{|e| e[:url].empty?}),
      }
    end

    private
    def get_rawdata(calid)
      resp = Net::HTTP.get_response(URI('https://adventar.org/calendars/%d' % calid))
      return nil if resp.code.to_i != 200

      noko = Nokogiri.parse resp.body
      {
        title: noko.title,
        desc: noko.css('meta[name="description"]')[0]['content'],
        url: ('https://adventar.org/calendars/%d' % calid),
        data: (JSON.parse noko.css('div[data-react-class="CalendarContainer"]')[0]['data-react-props']),
      }
    end
  end
end
