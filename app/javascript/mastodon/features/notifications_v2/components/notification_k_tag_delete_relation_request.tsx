import { FormattedMessage } from 'react-intl';

import ReplyIcon from '@/material-icons/400-24px/reply-fill.svg?react';
import api from 'mastodon/api';
import { Avatar } from 'mastodon/components/avatar';
import type { NotificationGroupKTagDeleteRelationRequest } from 'mastodon/models/notification_group';

import type { LabelRenderer } from './notification_group_with_status';
import { NotificationWithStatus } from './notification_with_status';

const mentionLabelRenderer: LabelRenderer = () => (
  <FormattedMessage id='notification.label.mention' defaultMessage='Mention' />
);

export const NotificationKTagAddRelationRequestApproved: React.FC<{
  notification: NotificationGroupKTagDeleteRelationRequest;
  unread: boolean;
}> = ({ notification, unread }) => {
  const kTagDeleteRelationRequest = notification.k_tag_add_relation_request

  function approveRequest(){
    api().post(`/api/v1/k_tag_delete_relation_requests/${kTagDeleteRelationRequest.id}/approve`).then(response => {
      // リクエストが受け付けられたら　request_status に合わせてボタンの上体を更新
      request_status = response.data.request_status
    }).catch(error => {NotificationKTagDeleteRelationRequestApproved

    });
  }
  function denyRequest(){
    api().post(`/api/v1/k_tag_add_relation_requests/${kTagDeleteRelationRequest.id}/deny`).then(response => {
      // リクエストが受け付けられたら　request_status に合わせてボタンの上体を更新
      request_status = response.data.request_status
    }).catch(error => {

    });
  }

  return (
    <div>


      {/* {kTagAddRelationRequest.request_status === 0 && ( */}

        <div>
          <div>
            {kTagDeleteRelationRequest.k_tag.name}
            <div className='account__avatar-wrapper'>
                        <Avatar withLink account={kTagDeleteRelationRequest.requester as Account} size={36} />
                      </div>

                        {kTagDeleteRelationRequest.requester.acct}

          </div>
          <button onClick={approveRequest}>
            承諾
          </button>
          <button onClick={denyRequest}>
            拒否
          </button>
        </div>
      {/* )} */}
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
