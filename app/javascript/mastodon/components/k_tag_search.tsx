import React, { useCallback, useState } from 'react';

import { useSelector, useDispatch } from 'react-redux';

import ReactTags from 'react-tag-autocomplete';
import type { Tag } from 'react-tag-autocomplete/index';

import { useLazyFetchKTagsByTextQuery } from 'mastodon/api/k_tags';
import type { KTag } from 'mastodon/features/search/search_by_k_tag';
import {addKTag, removeKTag, selectAllSuggestions, selectAllSelected} from 'mastodon/slices/k_tag_search_slice';
import { useAppSelector  } from 'mastodon/store';
import type {RootState} from 'mastodon/store';


export const KTagSearch = () => {
  const dispatch = useDispatch();
  const suggestions: Tag[] = useAppSelector((state: RootState) => selectAllSuggestions(state) as Tag[]);
  const selectedTags: Tag[] = useAppSelector((state: RootState) => selectAllSelected(state) as Tag[]);

  const onAdd = useCallback(
    (tag: Tag) => {
      dispatch(addKTag(tag as KTag));
    },
    [dispatch]
  );

  const onDelete = useCallback(
    (index: number) => {
      const tag = selectedTags[index];
      if (tag && typeof tag.id === 'number') {
        dispatch(removeKTag(tag.id));
      }
    },
    [dispatch, selectedTags]
  );

  const [trigger, { data, error, isLoading }] = useLazyFetchKTagsByTextQuery();

  const onInput = useCallback(
    (value: string) => {
      void trigger(value);
    },
    [trigger]
  );

  return (
    <ReactTags
      tags={selectedTags}
      suggestions={suggestions}
      onAddition={onAdd}
      onDelete={onDelete}
      onInput={onInput}
      placeholderText={ "タグを入力"}
    />
  );

}


