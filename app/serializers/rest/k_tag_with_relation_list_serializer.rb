# frozen_string_literal: true

class REST::KTagWithRelationListSerializer < ActiveModel::Serializer
  attributes :added_k_tag_relation_list, :adding_k_tag_relation_requested_list, :deleting_k_tag_relation_requested_list

  def adding_k_tag_relation_requested_list
    object.adding_k_tag_relation_requested_list.map do |tag|
      REST::KTagAddRelationRequestSerializer.new(tag).attributes
    end
  end

  def added_k_tag_relation_list
    REST::KTagRelationSerializer.new(object.k_tag_relations.filter_map{ |tag| !tag.k_tag_delete_relation_requests.empty?}
    )
  end

  def deleting_k_tag_relation_requested_list
    REST::KTagRelationSerializer.new(object.k_tag_relations.filter_map{ |tag| tag.k_tag_delete_relation_requests.empty?})
  end

end