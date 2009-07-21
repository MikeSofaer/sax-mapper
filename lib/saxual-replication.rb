require '../sax-machine/lib/sax-machine'
require 'dm-core'

module SAXualReplication
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

    def columns_with_types
      column_names.each{|c| yield c, data_class(c) || String}
    end

    def connection
      DataMapper.repository(:default).adapter
    end

    def table(value)
      @table_name = value
    end

    def datamapper_class
      klass = self.dup
      klass.send(:include, DataMapper::Resource)
      klass.storage_names[:default] = @table_name
      klass.property(:id, DataMapper::Types::Serial)
      klass.property(:created_at, DateTime, :nullable => false)
      klass.property(:updated_at, DateTime, :nullable => false)
      columns_with_types { |n, t| klass.property(n, t) }
      klass
    end

    def sql(rows)
      "INSERT INTO "+ @table_name + "(" + column_names.join(', ') + ", created_at, updated_at) VALUES " +
        ([("(" + (["?"] * (column_names.size + 2)).join(',') + ")")] * rows.size).join(',')
    end
    def bind_values(rows)
      names = column_names
      datetime = DateTime.now
      array = []
      rows.each{|row| row.add_bind_values!(names, array, datetime)}
      array
    end

    def save(rows)
      connection.execute sql(rows), *bind_values(rows)
    end
  end


  def sql
    columns = self.class.model.columns
    ret = "INSERT INTO #{self.class.table_name} (#{columns.join(', ')}) values "
    values = send(self.class.table_name).map{|o| o.sql_values_string(columns)}
    update_columns = columns - [:sourced_id, :id, :created_at]
    update_keys = update_columns.map{|c| c.to_s + '=VALUES(' + c.to_s + ')'}
    ret + values.join(', ') + " ON DUPLICATE KEY UPDATE " + update_keys.join(', ')
  end

  def add_bind_values!(column_names, bind_array, datetime)
    column_names.each{|c| bind_array << self.send(c)}
    bind_array << datetime << datetime
  end

  def save!
    return save_with(self.class.container.constantize) if self.class.container
    self.class.connection.execute sql
  end

  def save_with(container_class)
    c = container_class.new
    c.collection = [self]
    c.save!
  end

  def validate
    self.class.instance_variable_get('@sax_config').instance_variable_get('@top_level_elements').select{ |e| e.required? }.each do |element|
      raise MissingElementError.new("Missing the required attribute " + element.name) unless send(element.instance_variable_get('@as'))
    end

    #send(self.class.table_name).each{ |o| o.validate } if self.class.table_name
  end

  def collection
    send(table_name)
  end

  def collection=(values)
    send(table_name + '=', values)
  end
end