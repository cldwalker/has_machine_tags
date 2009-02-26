require File.join(File.dirname(__FILE__), 'test_helper')

class HasMachineTagsTest < Test::Unit::TestCase
  context "TagList" do
    before(:each) { @taggable = TaggableModel.new }
    
    test "sets tag list with array" do
      arr = ['some', 'tag:name=blah']
      @taggable.tag_list = arr
      @taggable.tag_list.should == arr
    end
    
    test "sets tag list with delimited string" do
      arr = ['more', 'tag:type=clever']
      @taggable.tag_list = arr.join(", ")
      @taggable.tag_list.should == arr
    end
    
    test "sets tag list with messy delimited string" do
      arr = ['more', 'tag:type=dumb', 'really']
      @taggable.tag_list = "more,tag:type=dumb,   really"
      @taggable.tag_list.should == arr
      @taggable.tag_list.to_s.should == arr.join(", ")
    end
    
    context "with quick_mode" do
      before(:all) { TaggableModel.quick_mode = true }
      after(:all) { TaggableModel.quick_mode = false }
      
      test "sets tag list normally with non quick_mode characters" do
        arr = ['more', 'tag:type=dumb', 'really']
        @taggable.tag_list = "more,tag:type=dumb,   really"
        @taggable.tag_list.should == arr
      end
      
      test "sets default predicate and infers namespace" do
        @taggable.tag_list = "gem:irb;name=utility_belt, article"
        @taggable.tag_list.should == ["gem:tags=irb", "gem:name=utility_belt", "article"]
      end
    end
  end
  
  context "InstanceMethods" do
    before(:each) { @taggable = TaggableModel.new }
  
    test "creates all tags" do
      tags = ['some', 'tag:name=blah']
      @taggable.tag_list = tags
      @taggable.save!
      @taggable.tags.map(&:name).should == tags
    end
    
    test "only creates new tags" do
      @taggable.tag_list = "bling"
      @taggable.save!
      tag_count = Tag.count
      @taggable.tag_list = "bling, bling2"
      @taggable.save!
      @taggable.taggings.size.should == 2
      Tag.count.should == tag_count + 1
    end
    
    test "deletes unused tags" do
      @taggable.tag_list == 'bling, bling3'
      @taggable.save!
      @taggable.tag_list = "bling4"
      @taggable.save!
      @taggable.taggings.size.should == 1
      @taggable.tags.map(&:name).should == ['bling4']
    end
  end
end
