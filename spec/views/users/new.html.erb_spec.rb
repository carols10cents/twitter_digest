require 'spec_helper'

describe "users/new.html.erb" do
  before(:each) do
    assign(:user, stub_model(User,
      :provider => "MyString",
      :uid => "MyString",
      :name => "MyString",
      :timeline_order => "",
      :conversation_order => ""
    ).as_new_record)
  end

  it "renders new user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => users_path, :method => "post" do
      assert_select "input#user_provider", :name => "user[provider]"
      assert_select "input#user_uid", :name => "user[uid]"
      assert_select "input#user_name", :name => "user[name]"
      assert_select "input#user_timeline_order", :name => "user[timeline_order]"
      assert_select "input#user_conversation_order", :name => "user[conversation_order]"
    end
  end
end
