import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

import type { ApiKTagJSON } from "../api_types/k_tags";
import type { KTag } from "../features/search/search_by_k_tag";

export type { ApiKTagJSON };

export const kTagsApiSlice = createApi({
  reducerPath: "kTagsApi",
  baseQuery: fetchBaseQuery({ baseUrl: "/api/v2" }),
  endpoints: (builder) => ({
    getKTag: builder.query<KTag,  number[] | string[]>({
      // The URL for the request is '/fakeApi/posts'
      query: ids => ({
        url: '/k_tags',
        params: { ids } // { ids: [1, 2, 3] } のようにオブジェクトで渡す
      }),
    }),
    fetchKTagsByText: builder.query<ApiKTagJSON[], string>({
      query: (text) => ({
        url: "/search",
        method: "GET",
        params: { q: text, type: "k_tags" },
      }),
      transformResponse: (response: { k_tags: ApiKTagJSON[] }) => response.k_tags,
    }),
  }),
});

export const { useFetchKTagsByTextQuery, useGetKTagQuery,useLazyFetchKTagsByTextQuery } = kTagsApiSlice;
