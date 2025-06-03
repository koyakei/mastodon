class TagRelationService < BaseService
  include Redisable
  include LanguagesHelper
  class UnexpectedMentionsError < StandardError
    attr_reader :accounts

    def initialize(message, accounts)
      super(message)
      @accounts = accounts
    end
  end

  def create(account, k_tag , status)

    # The following transaction block is needed to wrap the UPDATEs to maintain unique tag relation
    ApplicationRecord.transaction do
      KTagRelation.new(account: account, k_tag: k_tag, status: status)
    end
  end

end

class ProcessTagsService < BaseService
  include Payloadable
  def call(status)
    @status = status
    return unless @status.local?
  end
end