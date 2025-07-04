import type { PayloadAction } from "@reduxjs/toolkit";
import { createSlice } from "@reduxjs/toolkit";

import { Tag } from "react-tag-autocomplete";

import { kTagsApiSlice } from "mastodon/api/k_tags";
import type { KTag } from "mastodon/features/search/search_by_k_tag";
import type { RootState } from "../store";

interface KTagSearchState {
  selectedKTags: KTag[];
  suggestions: KTag[];
}

const initialState: KTagSearchState = {
  selectedKTags: [],
  suggestions: [],
};

const kTagSearchSlice = createSlice({
  name: "kTagSearch",
  initialState,
  reducers: {
    setSelectedKTags: (state, action: PayloadAction<KTag[]>) => {
      state.selectedKTags = action.payload;
    },
    addKTag: (state, action: PayloadAction<KTag>) => {
      if (!state.selectedKTags.some(kTag => kTag.id === action.payload.id)) {
        state.selectedKTags.push(action.payload);
      }
    },
    removeKTag: (state, action: PayloadAction<number>) => {
      state.selectedKTags.splice(action.payload, 1);
    },
  },
  extraReducers: builder => {
      builder.addMatcher(
        kTagsApiSlice.endpoints.fetchKTagsByText.matchFulfilled,
        (state, action) => {
          const kTags = action.payload;
          kTags.forEach((kTag: KTag) => {
            if (!state.suggestions.some(existingKTag => existingKTag.id === kTag.id)) {
              state.suggestions.push(kTag);
            }
          });
        }
      );
    },
});

export const { setSelectedKTags, addKTag, removeKTag } = kTagSearchSlice.actions;

export const selectAllSuggestions = (state: RootState) => state.kTagSearchSliceReducer.suggestions;

export const selectAllSelected = (state: RootState) => state.kTagSearchSliceReducer.selectedKTags;

export default kTagSearchSlice.reducer;
