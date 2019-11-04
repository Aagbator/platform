require 'rails_helper'

RSpec.describe "contents/new", type: :view do
  before(:each) do
    assign(:content, Content.new(
      :title => "MyString",
      :body => "MyText",
      :type => "MyText"
    ))
  end

  it "renders new content form" do
    render

    assert_select "form[action=?][method=?]", contents_path, "post" do

      assert_select "input[name=?]", "content[title]"

      assert_select "textarea[name=?]", "content[body]"

      assert_select "textarea[name=?]", "content[type]"
    end
  end
end
