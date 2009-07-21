require File.dirname(__FILE__) + '/../spec_helper'

describe "SAXMachine" do
  before :each do
    @klass = Class.new do
      include SAXualReplication
      element :title
      element :written_on, :class => DateTime
      table "documents"
    end
  end
  it "should function as a SAXMachine class" do
    document = @klass.parse("<title>Hello, Everyone!</title>")
    document.title.should == "Hello, Everyone!"
  end
  describe "DataMapper" do
    before(:each) do
      DataMapper.setup(:default, 'mysql://localhost/saxual_replication_test')
      @adapter = DataMapper.repository.adapter
    end
    it "should have the database connection" do
      @adapter.query "show tables"
    end
    it "should have a DataMapper class" do
      @klass.datamapper_class.all.should be_a(Array)
    end
    it "should be able to auto-migrate the document table" do
      DataMapper.auto_migrate!
    end
    describe "with multiple columns" do
      before(:each) do
        @document = @klass.parse("<xml><title>Someone's Cat</title><written_on>March 5 2007</written_on></xml>")
      end
      it "should generate the correct bind values for the specified columns" do
        @klass.column_names.should =~ [:title, :written_on]
        array = []
        @document.add_bind_values!(@klass.column_names, array, DateTime.now)
        array[0].should == "Someone's Cat"
        array[1].should be_a(DateTime)
        array[2].should be_a(DateTime)
        array[3].should be_a(DateTime)
      end
      it "should generate the correct bind values from a class call" do
        array = @klass.bind_values([@document,@document])
        array[0].should == "Someone's Cat"
        array[4].should == "Someone's Cat"
        array[1].should be_a(DateTime)
        array[5].should be_a(DateTime)
      end
      it "should generate the correct SQL from a class call" do
        @klass.sql([@document,@document]).should == "INSERT INTO documents(title, written_on, created_at, updated_at) VALUES (?,?,?,?),(?,?,?,?)"
      end
      it "should be able to save a record" do
        document = @klass.parse("<title>Hello, Everyone!</title>")
        @klass.save [@document,@document]
        @klass.datamapper_class.all[0].title.should == "Someone's Cat"
        @klass.datamapper_class.all[1].title.should == "Someone's Cat"
      end
    end
  end
end