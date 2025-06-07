import { useMemo } from 'react';

import classNames from 'classnames';

import { HotKeys } from 'react-hotkeys';

import { replyComposeById } from 'mastodon/actions/compose';
import { toggleReblog, toggleFavourite } from 'mastodon/actions/interactions';
import {
  navigateToStatus,
  toggleStatusSpoilers,
} from 'mastodon/actions/statuses';
import api from 'mastodon/api';
import type { ApiKTagAddRelationRequestJSON }from 'mastodon/api_types/statuses';
import type { IconProp } from 'mastodon/components/icon';
import { Icon } from 'mastodon/components/icon';
import { StatusQuoteManager } from 'mastodon/components/status_quoted';
import { getStatusHidden } from 'mastodon/selectors/filters';
import { useAppSelector, useAppDispatch } from 'mastodon/store';

import { DisplayedName } from './displayed_name';
import type { LabelRenderer } from './notification_group_with_status';


export const NotificationKTagAddRelationRequest: React.FC<{
  type: string;
  icon: IconProp;
  iconId: string;
  accountIds: string[];
  statusId: string | undefined;
  count: number;
  labelRenderer: LabelRenderer;
  unread: boolean;
  kTagAddRelationRequest?: ApiKTagAddRelationRequestJSON;
}> = ({
  icon,
  iconId,
  accountIds,
  statusId,
  count,
  labelRenderer,
  type,
  unread,
  kTagAddRelationRequest,
}) => {
  const dispatch = useAppDispatch();
  let requestStatus = kTagAddRelationRequest?.status || 'pending';
  const label = useMemo(
    () => labelRenderer(<DisplayedName accountIds={accountIds} />, count),
    [labelRenderer, accountIds, count],
  );

  const isPrivateMention = useAppSelector(
    (state) => state.statuses.getIn([statusId, 'visibility']) === 'direct',
  );

  const isFiltered = useAppSelector(
    (state) =>
      statusId &&
      getStatusHidden(state, { id: statusId, contextType: 'notifications' }),
  );

  const handlers = useMemo(
    () => ({
      open: () => {
        dispatch(navigateToStatus(statusId));
      },

      reply: () => {
        dispatch(replyComposeById(statusId));
      },

      boost: () => {
        dispatch(toggleReblog(statusId));
      },

      favourite: () => {
        dispatch(toggleFavourite(statusId));
      },

      toggleHidden: () => {
        dispatch(toggleStatusSpoilers(statusId));
      },
    }),
    [dispatch, statusId],
  );

  if (!statusId || isFiltered) return null;


  function approveRequest() {
    api().post(`/api/v1/k_tag_add_relation_requests/${kTagAddRelationRequestId}/approve`)
      .then(() => {
        requestStatus = 'approved';
      })
      .catch((error) => {
        // Handle error, e.g., show an error message
        console.error('Error approving request:', error);
      });
  }

  function denyRequest() {
    api().post(`/api/v1/k_tag_add_relation_requests/${kTagAddRelationRequestId}/deny`)
      .then(() => {
        // Handle success, e.g., show a success message or update the UI
        requestStatus = 'denied';
      })
      .catch((error) => {
        // Handle error, e.g., show an error message
        console.error('Error denying request:', error);
      });
  }

  return (
    <HotKeys handlers={handlers}>
      <div
        role='button'
        className={classNames(
          `notification-ungrouped focusable notification-ungrouped--${type}`,
          {
            'notification-ungrouped--unread': unread,
            'notification-ungrouped--direct': isPrivateMention,
          },
        )}
        tabIndex={0}
      >
        <div className='notification-ungrouped__header'>
          <div className='notification-ungrouped__header__icon'>
            <Icon icon={icon} id={iconId} />
          </div>
          {label}
        </div>
        if (requestStatus === 'approved') {
          <div>
            承諾ずみ
          </div>
        } else if (requestStatus === 'denied') {
          <div>
            拒否ずみ
          </div>
        } else {
          <div className='notification-ktag-add-requests__content'>
            <div className='notification-ktag-add-requests__content__text'>
              <button onClick={approveRequest}>
                承諾
              </button>
              <button onClick={denyRequest}>
                拒否
              </button>
            </div>
          </div>
        }

        <StatusQuoteManager
          id={statusId}
          contextType='notifications'
          withDismiss
          skipPrepend
          avatarSize={40}
          unfocusable
        />
      </div>
    </HotKeys>
  );
};
