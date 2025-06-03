require 'rails_helper'

RSpec.describe "k_tag_add_relation_requests/show", type: :view do
  before(:each) do
    assign(:k_tag_add_relation_request, KTagAddRelationRequest.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
