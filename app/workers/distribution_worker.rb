# frozen_string_literal: true

class DistributionWorker
  include Sidekiq::Worker
  include Redisable
  include Lockable

  def perform(status_id, options = {})
    with_redis_lock("distribute:#{status_id}") do
      FanOutOnWriteService.new.call(Status.includes(:account, :k_tag_add_relation_requests , k_tag_relations: :k_tag).find(status_id), **options.symbolize_keys)
    end
  rescue ActiveRecord::RecordNotFound
    true
  end
end
