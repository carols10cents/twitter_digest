require 'spec_helper'

describe "users/edit.html.erb" do
  before(:each) do
    @user = assign(:user, stub_model(User,
      :provider => "MyString",
      :uid => "MyString",
      :name => "MyString",
      :timeline_order => "",
      :conversation_order => ""
    ))
  end

  it "renders the edit user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => users_path(@user), :method => "post" do
      assert_select "input#user_provider", :name => "user[provider]"
      assert_select "input#user_uid", :name => "user[uid]"
      assert_select "input#user_name", :name => "user[name]"
      assert_select "input#user_timeline_order", :name => "user[timeline_order]"
      assert_select "input#user_conversation_order", :name => "user[conversation_order]"
    end
  end
end
