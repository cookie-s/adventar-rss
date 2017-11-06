require 'google/cloud/datastore'
require 'yaml'

class History
  class << self
    def datastore
      @@datastore
    end
    def establish(config)
      @@datastore = Google::Cloud::Datastore.new(
        project: config['project_id'],
      )
      nil
    end

    def find_old(eid)
      query = datastore.query('UpdatedAt').
        where('entryid', '=', eid).
        where('updated', '<', Time.now)
      res = datastore.run query
      return nil if res.empty?
      res[0]
    end

    def update(eid)
      e = datastore.entity 'UpdatedAt' do |e|
        e['entryid'] = eid
        e['updated'] = Time.now
      end
      datastore.save e
      nil
    end
  end
end
