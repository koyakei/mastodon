require 'rails_helper'

RSpec.describe "k_tag_delete_relation_requests/edit", type: :view do
  let(:k_tag_delete_relation_request) {
    KTagDeleteRelationRequest.create!()
  }

  before(:each) do
    assign(:k_tag_delete_relation_request, k_tag_delete_relation_request)
  end

  it "renders the edit k_tag_delete_relation_request form" do
    render

    assert_select "form[action=?][method=?]", k_tag_delete_relation_request_path(k_tag_delete_relation_request), "post" do
    end
  end
end
