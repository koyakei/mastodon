import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

import type { KTag } from "mastodon/features/search/search_by_k_tag";

import type { ApiKTagJSON } from "../api_types/k_tags";

export type { ApiKTagJSON };

export const kTagsApiSlice = createApi({
  reducerPath: "kTagsApi",
  baseQuery: fetchBaseQuery({ baseUrl: "" }),
  endpoints: (builder) => ({
    getKTag: builder.query<KTag[],  number[] | string[]>({
      // The URL for the request is '/fakeApi/posts'
      query: ids => ({
        url: '/k_tags',
        params: { 'ids[]': ids }
      }),
      transformResponse: (response: ApiKTagJSON[] )  => {
        return response.map((kTag) => (
          {
          id: kTag.id, // Convert string ID to number
          name: kTag.name,
          isOwned: false, // Assuming isOwned is false by default, adjust as needed
        }
      ));
      }
    }),
    fetchKTagsByText: builder.query<KTag[], string>({
      query: (text) => ({
        url: "/api/v2/search",
        method: "GET",
        params: { q: text, type: "k_tags" },
      }),
      transformResponse: (response: { k_tags: ApiKTagJSON[] })  => {
        const k_tagarray : KTag[] = response.k_tags.map((kTag) => ({
          id: kTag.id, // Convert string ID to number
          name: kTag.name,
          isOwned: false, // Assuming isOwned is false by default, adjust as needed
        }));
        return k_tagarray;
      }
    }),
  }),
});

export const { useFetchKTagsByTextQuery, useGetKTagQuery, useLazyFetchKTagsByTextQuery } = kTagsApiSlice;
