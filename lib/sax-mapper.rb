require 'sax-machine'
require 'dm-core'
require 'enumerator'

module SaxMapper
  class MissingElementError < Exception; end

  def self.included(base)
    base.send(:include, SAXMachine)
    base.extend SaverMethods
  end

  module SaverMethods
    def parse(xml)
      ret = super(xml)
      ret.validate
      return ret
    end

    def parse_multiple(xml)
      klass = collection_class
      ret = klass.parse(xml)
      ret.rows.each{|o| o.validate}
      ret.rows
    end

    def columns_with_types
      column_names.each{|c| yield c, data_class(c) || String}
    end

    def connection
      DataMapper.repository(:default).adapter
    end

    def table(value)
      @table_name = value
    end

    def tag(value)
      @tag = value
    end

    def key_column(value)
      @key_column = value
    end

    def datamapper_class
      klass = self.dup
      klass.send(:include, DataMapper::Resource)
      klass.storage_names[:default] = @table_name
      klass.property(:id, DataMapper::Types::Serial)
      klass.property(:created_at, DateTime, :nullable => false)
      klass.property(:updated_at, DateTime, :nullable => false)
      columns_with_types { |n, t| klass.property(n, t, :field => n.to_s) }
      klass
    end

    def collection_class
      klass = self
      tag = @tag
      Class.new do
        include SaxMapper
        elements tag, :as => :rows, :class => klass
      end
    end

    def sql(rows)
      _sql = "INSERT INTO "+ @table_name + "(" + column_names.join(', ') + ", created_at, updated_at) VALUES " +
        ([("(" + (["?"] * (column_names.size + 2)).join(',') + ")")] * rows.size).join(',')
      _sql << duplicate_key_clause if @key_column
      _sql
    end
    def bind_values(rows)
      names = column_names
      datetime = DateTime.now
      array = []
      rows.each{|row| row.add_bind_values!(names, array, datetime)}
      array
    end
    def duplicate_key_clause
      " ON DUPLICATE KEY UPDATE " + (column_names - [:created_at, @key_column]).map {|c| c.to_s + "=VALUES(" + c.to_s + ")"}.join(', ')
    end

    def save(rows, options = {})
      if options[:batch_size]
        rows.each_slice(options[:batch_size]) do |batch|
          connection.execute sql(batch), *bind_values(batch)
        end
      else
        connection.execute sql(rows), *bind_values(rows)
      end
    end
  end

  def add_bind_values!(column_names, bind_array, datetime)
    column_names.each do |c|
      val = self.send(c)
      bind_array << ((self.class.data_class(c) == DateTime && val) ? (DateTime.parse(val)) : val)
    end
    bind_array << datetime << datetime
  end

  def validate
    self.class.instance_variable_get('@sax_config').instance_variable_get('@top_level_elements').select{ |e| e.required? }.each do |element|
      raise MissingElementError.new("Missing the required attribute " + element.name) unless send(element.instance_variable_get('@as'))
    end
  end
end