# frozen_string_literal: true

class REST::NotificationSerializer < ActiveModel::Serializer
  attributes :id, :type, :created_at

  belongs_to :from_account, key: :account, serializer: REST::AccountSerializer
  belongs_to :target_status, key: :status, if: :status_type?, serializer: REST::StatusSerializer
  belongs_to :report, if: :report_type?, serializer: REST::ReportSerializer
  belongs_to :account_relationship_severance_event, key: :event, if: :relationship_severance_event?, serializer: REST::AccountRelationshipSeveranceEventSerializer
  belongs_to :account_warning, key: :moderation_warning, if: :moderation_warning_event?, serializer: REST::AccountWarningSerializer
  belongs_to :k_tag_add_relation_request_for_user, if: :k_tag_add_relation_request_type?, serializer: REST::KTagAddRelationRequestForUserSerializer, class_name: "KTagAddRelationRequest"
  belongs_to :k_tag_delete_relation_request, if: :k_tag_delete_relation_request_type?, serializer: REST::KTagDeleteRelationRequestSerializer

  def id
    object.id.to_s
  end

  def status_type?
    [:favourite, :reblog, :status, :mention, :poll, :update].include?(object.type)
  end

  def k_tag_add_relation_request_type?
    [:k_tag_add].include?(object.type)
  end

  def k_tag_delete_relation_request_type?
    [:k_tag_delete].include?(object.type)
  end


  def report_type?
    object.type == :'admin.report'
  end

  def relationship_severance_event?
    object.type == :severed_relationships
  end

  def moderation_warning_event?
    object.type == :moderation_warning
  end
end
