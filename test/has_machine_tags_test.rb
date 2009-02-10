require File.join(File.dirname(__FILE__), 'test_helper')

class HasMachineTagsTest < Test::Unit::TestCase
  context "TagList" do
    before(:each) { @taggable = TaggableModel.new }
    
    test "sets tag list with array" do
      arr = ['some', 'tags:name=blah']
      @taggable.tag_list = arr
      @taggable.tag_list.should == arr
    end
    
    test "sets tag list with delimited string" do
      arr = ['more', 'tags:type=clever']
      @taggable.tag_list = arr.join(", ")
      @taggable.tag_list.should == arr
    end
    
    test "sets tag list with messy delimited string" do
      arr = ['more', 'tags:type=dumb', 'really']
      @taggable.tag_list = "more,tags:type=dumb,   really"
      @taggable.tag_list.should == arr
    end
  end
  
  context "HasMachineTags" do
    before(:each) { @taggable = TaggableModel.new }
  
    test "creates new tags" do
      tags = ['some', 'tags:name=blah2']
      @taggable.tag_list == tags
      @taggable.save
      # @taggable.tags.map(&:name).should == tags
    end
  end
end
