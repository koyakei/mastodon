require 'rails_helper'

RSpec.describe "k_tag_delete_relation_requests/show", type: :view do
  before(:each) do
    assign(:k_tag_delete_relation_request, KTagDeleteRelationRequest.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
