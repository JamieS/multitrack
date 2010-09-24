require 'active_record'
require 'logger'

ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.logger = Logger.new(File.expand_path('../../../log/production.log', __FILE__))

dbconfig = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection dbconfig['production']

class << ActiveRecord::Schema
  def apply(options, &block)
    define(options, &block) unless migrated_to?(options[:version])
  end

  private
    def migrated_to?(version)
      ActiveRecord::Base.connection.select_value("SELECT 'found' FROM schema_migrations WHERE version = #{version}") == 'found'
    rescue
      false
    end
end

# Schema

ActiveRecord::Schema.apply :version => 1 do
  create_table :visits, :force => true do |t|
    t.string :uid
    t.string :landing_page
    t.string :referrer
    t.datetime :created_at
  end

  add_index :visits, :uid
  add_index :visits, :created_at
end

ActiveRecord::Schema.apply :version => 2 do
  remove_index :visits, :uid
  remove_index :visits, :created_at

  add_index :visits, [:uid, :created_at]
  add_index :visits, :referrer
end
