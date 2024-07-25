require "rails_helper"

RSpec.describe KTagDeleteRelationRequestsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/k_tag_delete_relation_requests").to route_to("k_tag_delete_relation_requests#index")
    end

    it "routes to #new" do
      expect(get: "/k_tag_delete_relation_requests/new").to route_to("k_tag_delete_relation_requests#new")
    end

    it "routes to #show" do
      expect(get: "/k_tag_delete_relation_requests/1").to route_to("k_tag_delete_relation_requests#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/k_tag_delete_relation_requests/1/edit").to route_to("k_tag_delete_relation_requests#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/k_tag_delete_relation_requests").to route_to("k_tag_delete_relation_requests#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/k_tag_delete_relation_requests/1").to route_to("k_tag_delete_relation_requests#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/k_tag_delete_relation_requests/1").to route_to("k_tag_delete_relation_requests#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/k_tag_delete_relation_requests/1").to route_to("k_tag_delete_relation_requests#destroy", id: "1")
    end
  end
end
