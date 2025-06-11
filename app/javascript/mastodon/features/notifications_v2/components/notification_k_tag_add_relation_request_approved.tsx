import { FormattedMessage } from 'react-intl';

import ReplyIcon from '@/material-icons/400-24px/reply-fill.svg?react';
import { Avatar } from 'mastodon/components/avatar';
import type { NotificationGroupKTagAddRelationRequestApproved } from 'mastodon/models/notification_group';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationWithStatus } from './notification_with_status';

const mentionLabelRenderer: LabelRenderer = () => (
  <FormattedMessage id='notification.label.mention' defaultMessage='Mention' />
);

export const NotificationKTagAddRelationRequestApproved: React.FC<{
  notification: NotificationGroupKTagAddRelationRequestApproved;
  unread: boolean;
}> = ({ notification, unread }) => {
  const kTagAddRelationRequest = notification.k_tag_add_relation_request

  return (
    <div>
        <div>
          <div>
            {kTagAddRelationRequest.k_tag.name}
            <div className='account__avatar-wrapper'>
                        <Avatar withLink account={kTagAddRelationRequest.requester as Account} size={36} />
                      </div>
                        {kTagAddRelationRequest.requester.acct}
          </div>
          承諾された
        </div>
      <NotificationWithStatus
        type='mention'
        icon={ReplyIcon}
        iconId='reply'
        accountIds={notification.sampleAccountIds}
        count={notification.notifications_count}
        statusId={notification.status_id}
        labelRenderer={
            mentionLabelRenderer
        }
        unread={unread}
      />
      </div>
  );
};
