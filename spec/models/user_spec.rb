require 'spec_helper'

describe User do
  describe "#settings" do
    it "has newest first for initial timeline order" do
      u = User.create!
      u.settings.timeline_order.should eql(:newest_first)
    end
    
    it "has oldest first for initial conversation order" do
      u = User.create!
      u.settings.conversation_order.should eql(:oldest_first)
    end
    
    it "can change the prefs" do
      u = User.create!
      u.settings.timeline_order = :oldest_first
      u.settings.timeline_order.should eql(:oldest_first)
    end
    
    it "does not allow invalid values" do
      u = User.create!
      u.settings.conversation_order = :whatever_i_want
      u.should_not be_valid
    end
      
  end
end
