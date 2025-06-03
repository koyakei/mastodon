require 'rails_helper'

RSpec.describe "k_tag_add_relation_requests/new", type: :view do
  before(:each) do
    assign(:k_tag_add_relation_request, KTagAddRelationRequest.new())
  end

  it "renders new k_tag_add_relation_request form" do
    render

    assert_select "form[action=?][method=?]", k_tag_add_relation_requests_path, "post" do
    end
  end
end
