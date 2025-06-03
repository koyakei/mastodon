require 'rails_helper'

RSpec.describe "k_tag_delete_relation_requests/index", type: :view do
  before(:each) do
    assign(:k_tag_delete_relation_requests, [
      KTagDeleteRelationRequest.create!(),
      KTagDeleteRelationRequest.create!()
    ])
  end

  it "renders a list of k_tag_delete_relation_requests" do
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
  end
end
