# frozen_string_literal: true

class CreateKTagAddRelationRequestService < BaseService
  include Payloadable

  def call(account, k_tag_add_relation_request)
    @account = account
    ActivityPub::AccountRawDistributionWorker.perform_async(
        build_json(k_tag_add_relation_request), account.id) if @account.local?
  end

  private

  def build_json(k_tag_add_relation_request)
    ## TODO write serialzer
    Oj.dump(serialize_payload(k_tag_add_relation_request, ActivityPub::AddSerializer, signer: @account))
  end
end
