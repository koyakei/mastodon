import { FormattedMessage } from 'react-intl';

import { createAccountFromServerJSON } from '@/mastodon/models/account';
import ReplyIcon from '@/material-icons/400-24px/reply-fill.svg?react';
import { Avatar } from 'mastodon/components/avatar';
import type { NotificationGroupKTagDeleteRelationRequestDenied } from 'mastodon/models/notification_group';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationWithStatus } from './notification_with_status';

const mentionLabelRenderer: LabelRenderer = () => (
  <FormattedMessage id='notification.label.mention' defaultMessage='Mention' />
);

export const NotificationKTagDeleteRelationRequestDenied: React.FC<{
  notification: NotificationGroupKTagDeleteRelationRequestDenied;
  unread: boolean;
}> = ({ notification, unread }) => {
  const request = notification.kTagDeleteRelationRequest

  return (
    <div>
        <div>
          <div>
            {request.k_tag.name}
            <div className='account__avatar-wrapper'>
                        <Avatar withLink account={createAccountFromServerJSON(request.requester)} size={36} />
                      </div>
                        {request.requester.acct}
          </div>
          拒否された
        </div>
      <NotificationWithStatus
        type='mention'
        icon={ReplyIcon}
        iconId='reply'
        accountIds={notification.sampleAccountIds}
        count={notification.notifications_count}
        statusId={notification.statusId}
        labelRenderer={
            mentionLabelRenderer
        }
        unread={unread}
      />
      </div>
  );
};
