require File.join(File.dirname(__FILE__), 'test_helper')

def create_extra_taggable
	TaggableModel.create(:tag_list=>"blah:blih=bluh")
end

describe "Finder" do
  before { [Tag, Tagging, TaggableModel].each {|e| e.delete_all} }

  describe "TaggableModel" do
    describe "finds by" do
      before {
        @taggable = TaggableModel.create(:tag_list=>"url:lang=ruby")
        create_extra_taggable
      }
    
      it "namespace wildcard machine tag" do
        TaggableModel.tagged_with("url:").should == [@taggable]
      end
    
      it "predicate wildcard machine tag" do
        TaggableModel.tagged_with("lang=").should == [@taggable]
      end
    
      it "value wildcard machine tag" do
        TaggableModel.tagged_with("=ruby").should == [@taggable]
      end
    
      it "namespace-value wildcard machine tag" do
        TaggableModel.tagged_with("url.ruby").should == [@taggable]
      end
      
      it "predicate-value wildcard machine tag" do
        TaggableModel.tagged_with("lang=ruby").should == [@taggable]
      end
    end
    
    describe "finds with" do
      it "multiple machine tags as an array" do
        @taggable = TaggableModel.create(:tag_list=>"article:todo=later")
        @taggable2 = TaggableModel.create(:tag_list=>"article:tags=funny")
        create_extra_taggable
        results = TaggableModel.tagged_with(["article:todo=later", "article:tags=funny"])
        results.size.should == 2
        results.include?(@taggable).should == true
        results.include?(@taggable2).should == true
      end
      
      it "multiple machine tags as a delimited string" do
        @taggable = TaggableModel.create(:tag_list=>"article:todo=later")
        @taggable2 = TaggableModel.create(:tag_list=>"article:tags=funny")
        create_extra_taggable
        results = TaggableModel.tagged_with("article:todo=later, article:tags=funny")
        results.size.should == 2
        results.include?(@taggable).should == true
        results.include?(@taggable2).should == true
      end
      
      it "condition option" do
        @taggable = TaggableModel.create(:title=>"so limiting", :tag_list=>"url:tags=funny" )
        create_extra_taggable
        TaggableModel.tagged_with("url:tags=funny", :conditions=>"title = 'so limiting'").should == [@taggable]
      end
    end

    describe "when queried with normal tag" do
      before { @taggable = TaggableModel.new }
      it "doesn't find if machine tagged" do
        @taggable.tag_list = 'url:tags=square'
        @taggable.save
        Tag.count.should == 1
        TaggableModel.tagged_with("square").should == []
      end
    
      it "finds if tagged normally" do
        @taggable.tag_list = 'square, some:machine=tag'
        @taggable.save
        TaggableModel.tagged_with("square").should == [@taggable]
      end
    end        
  end  
end