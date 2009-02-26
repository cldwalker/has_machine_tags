require File.join(File.dirname(__FILE__), 'test_helper')

class HasMachineTags::FinderTest < Test::Unit::TestCase
  before(:each) { 
    [Tag, Tagging, TaggableModel].each {|e| e.delete_all}
  }
  
  def create_extra_taggable
    TaggableModel.create(:tag_list=>"blah:blih=bluh")
  end
  
  context "TaggableModel" do
    context "finds by" do
      before(:each) { 
        @taggable = TaggableModel.create(:tag_list=>"url:lang=ruby")
        create_extra_taggable
      }
    
      test "namespace wildcard machine tag" do
        TaggableModel.tagged_with("url:").should == [@taggable]
      end
    
      test "predicate wildcard machine tag" do
        TaggableModel.tagged_with("lang=").should == [@taggable]
      end
    
      test "value wildcard machine tag" do
        TaggableModel.tagged_with("=ruby").should == [@taggable]
      end
    
      test "namespace-value wildcard machine tag" do
        TaggableModel.tagged_with("url.ruby").should == [@taggable]
      end
      
      test "predicate-value wildcard machine tag" do
        TaggableModel.tagged_with("lang=ruby").should == [@taggable]
      end
    end
    
    context "finds with" do
      test "multiple machine tags as an array" do
        @taggable = TaggableModel.create(:tag_list=>"article:todo=later")
        @taggable2 = TaggableModel.create(:tag_list=>"article:tags=funny")
        create_extra_taggable
        results = TaggableModel.tagged_with(["article:todo=later", "article:tags=funny"])
        results.size.should == 2
        results.include?(@taggable).should be(true)
        results.include?(@taggable2).should be(true)
      end
      
      test "multiple machine tags as a delimited string" do
        @taggable = TaggableModel.create(:tag_list=>"article:todo=later")
        @taggable2 = TaggableModel.create(:tag_list=>"article:tags=funny")
        create_extra_taggable
        results = TaggableModel.tagged_with("article:todo=later, article:tags=funny")
        results.size.should == 2
        results.include?(@taggable).should be(true)
        results.include?(@taggable2).should be(true)
      end
      
      test "condition option" do
        @taggable = TaggableModel.create(:title=>"so limiting", :tag_list=>"url:tags=funny" )
        create_extra_taggable
        TaggableModel.tagged_with("url:tags=funny", :conditions=>"title = 'so limiting'").should == [@taggable]
      end
    end

    context "when queried with normal tag" do
      before(:each) { @taggable = TaggableModel.new }
      test "doesn't find if machine tagged" do
        @taggable.tag_list = 'url:tags=square'
        @taggable.save
        Tag.count.should == 1
        TaggableModel.tagged_with("square").should == []
      end
    
      test "finds if tagged normally" do
        @taggable.tag_list = 'square, some:machine=tag'
        @taggable.save
        TaggableModel.tagged_with("square").should == [@taggable]
      end
    end        
  end  
end