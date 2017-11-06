require 'sinatra/base'
require 'sinatra/config_file'

require 'rss'

require_relative 'model/history'
require_relative 'plugin/adventar'

class App < Sinatra::Base
  register Sinatra::ConfigFile

  config_file 'config/database.yml'
  configure do
    History.establish(settings.database)
  end

  get '/_ah/health' do
    'ok'
  end

  get '/api/adventar/:id' do
    content_type 'text/xml'

    res = Adventar.func( params[:id].to_i )
    return 404 if res.nil?

    rss = RSS::Maker.make('2.0') do |maker|
      #xss = maker.xml_stylesheets.new_xml_stylesheet
      #xss.href = "http://example.com/index.xsl"

      #maker.channel.about = "http://example.com/index.rdf"
      maker.channel.title = res[:title]
      maker.channel.description = res[:desc]
      maker.channel.link = res[:url]
      maker.items.do_sort = true

      res[:entries].each do |e|
        maker.items.new_item do |item|
          item.title = e[:title] || e[:url]
          item.date = e[:updated]
          item.link = e[:url]
        end
      end
    end

    rss.to_s
  end
end
