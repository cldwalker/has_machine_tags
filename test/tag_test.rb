require File.join(File.dirname(__FILE__), 'test_helper')

class HasMachineTags::TagTest < Test::Unit::TestCase
  test "create with normal tag name only touches name" do
    obj = Tag.create(:name=>'blah1')
    [:name, :namespace, :predicate, :value].map {|e| obj.send(e)}.should == ['blah1', nil, nil, nil]
  end
  
  test "create with machine tag name sets all name fields" do
    obj = Tag.create(:name=>'gem:name=machine')
    [:name, :namespace, :predicate, :value].map {|e| obj.send(e)}.should == ['gem:name=machine', 'gem', 'name', 'machine']
  end
  
  context "update" do
    before(:each) { @obj = Tag.new }
    
    test "with normal tag name only touches name" do
      @obj.update_attributes :name=> 'bling'
      [:name, :namespace, :predicate, :value].map {|e| @obj.send(e)}.should == ['bling', nil, nil, nil]
    end

    test "with machine tag name sets all name fields" do
      @obj.update_attributes :name=>'gem:prop=value'
      [:name, :namespace, :predicate, :value].map {|e| @obj.send(e)}.should == ['gem:prop=value', 'gem', 'prop', 'value']
    end

    test "with no name sets no name fields" do
      @obj.update_attributes :name=>'blah2'
      @obj.update_attributes :predicate=>'changed'
      @obj.name.should == 'blah2'
    end
  end
  
  context "match_wildcard_machine_tag" do
    test "matches namespace with asterisk" do
      Tag.match_wildcard_machine_tag('name:*=*').should == [[:namespace,'name']]
    end
    
    test "matches namespace without asterisk" do
      Tag.match_wildcard_machine_tag('name:').should == [[:namespace,'name']]
    end
    
    test "matches predicate with asterisk" do
      Tag.match_wildcard_machine_tag('*:pred=*').should == [[:predicate,'pred']]
    end
    
    test "matches predicate without asterisk" do
      Tag.match_wildcard_machine_tag('pred=').should == [[:predicate,'pred']]
    end
    
    test "matches value with asterisk" do
      Tag.match_wildcard_machine_tag('*:*=val').should == [[:value, 'val']]
    end
    
    test "matches value without asterisk" do
      Tag.match_wildcard_machine_tag('=val').should == [[:value, 'val']]
    end
    
    test "matches namespace and predicate without asterisk" do
      Tag.match_wildcard_machine_tag('name:pred').should == [[:namespace, 'name'], [:predicate, 'pred']]
    end
    
    test "matches predicate and value without asterisk" do
      Tag.match_wildcard_machine_tag('pred=val').should == [[:predicate, 'pred'], [:value, 'val']]
    end
    
    test "matches namespace and value without asterisk" do
      Tag.match_wildcard_machine_tag('name::val').should == [[:namespace, 'name'], [:value, 'val']]
    end
    
    test "doesn't match machine tag" do
      Tag.match_wildcard_machine_tag('name:pred=val').should == nil
    end
    
    test "doesn't match normal tag" do
      Tag.match_wildcard_machine_tag('name').should == nil
    end
  end
  
  test "validates name when no invalid characters" do
    Tag.new(:name=>'valid!name_really?').valid?.should be(true)
  end

  test "validates name when machine tag format" do
    Tag.new(:name=>'name:pred=value').valid?.should be(true)
  end

  test "invalidates name when invalid characters present" do
    %w{some.tag another:tag so=invalid yet,another whoop*}.each do |e|
      Tag.new(:name=>e).valid?.should be(false)
    end
  end
end
