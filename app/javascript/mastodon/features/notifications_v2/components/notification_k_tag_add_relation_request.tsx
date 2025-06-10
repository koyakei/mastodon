import { FormattedMessage } from 'react-intl';

import ReplyIcon from '@/material-icons/400-24px/reply-fill.svg?react';
import api from 'mastodon/api';
import { Avatar } from 'mastodon/components/avatar';
import { DisplayName } from 'mastodon/components/display_name';
import type { NotificationGroupKTagAddRelationRequest } from 'mastodon/models/notification_group';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationWithStatus } from './notification_with_status';

const mentionLabelRenderer: LabelRenderer = () => (
  <FormattedMessage id='notification.label.mention' defaultMessage='Mention' />
);

export const NotificationKTagAddRelationRequest: React.FC<{
  notification: NotificationGroupKTagAddRelationRequest;
  unread: boolean;
}> = ({ notification, unread }) => {
  const kTagAddRelationRequest = notification.k_tag_add_relation_request

  function approveRequest(){
    api().post(`/api/v1/k_tag_add_relation_requests/${kTagAddRelationRequest.id}/approve`).then(response => {
      // リクエストが受け付けられたら　request_status に合わせてボタンの上体を更新
      request_status = response.data.request_status
    }).catch(error => {

    });
  }
  function denyRequest(){
    api().post(`/api/v1/k_tag_add_relation_requests/${kTagAddRelationRequest.id}/deny`).then(response => {
      // リクエストが受け付けられたら　request_status に合わせてボタンの上体を更新
      request_status = response.data.request_status
    }).catch(error => {

    });
  }

  return (
    <div>


      {kTagAddRelationRequest.request_status === 0 && (

        <div>
          <div>
            <div className='account__avatar-wrapper'>
                        <Avatar withLink account={kTagAddRelationRequest.requester as Account} size={36} />
                      </div>

                        {kTagAddRelationRequest.requester.acct}

          </div>
          <button onClick={approveRequest}>
            承諾
          </button>
          <button onClick={denyRequest}>
            拒否
          </button>
        </div>
      )}
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
