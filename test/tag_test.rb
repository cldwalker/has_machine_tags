require File.join(File.dirname(__FILE__), 'test_helper')

class HasMachineTags::TagTest < Test::Unit::TestCase
  test "create with normal tag name only touches name" do
    obj = Tag.create(:name=>'blah1')
    [:name, :object, :property, :value].map {|e| obj.send(e)}.should == ['blah1', nil, nil, nil]
  end
  
  test "create with machine tag name sets all name fields" do
    obj = Tag.create(:name=>'gem:name=machine')
    [:name, :object, :property, :value].map {|e| obj.send(e)}.should == ['gem:name=machine', 'gem', 'name', 'machine']
  end
  
  context "update" do
    before(:each) { @obj = Tag.create(:name=>'blah2') }
    
    test "with normal tag name only touches name" do
      @obj.update_attributes :name=> 'bling'
      [:name, :object, :property, :value].map {|e| @obj.send(e)}.should == ['bling', nil, nil, nil]
    end

    test "with machine tag name sets all name fields" do
      @obj.update_attributes :name=>'gem:prop=value'
      [:name, :object, :property, :value].map {|e| @obj.send(e)}.should == ['gem:prop=value', 'gem', 'prop', 'value']
    end

    test "with no name sets no name fields" do
      @obj.update_attributes :property=>'changed'
      @obj.name.should == 'blah2'
    end
  end
end
