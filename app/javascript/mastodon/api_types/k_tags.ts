import type { ApiAccountJSON } from "./accounts";

export interface ApiKTagJSON {
    id: string;
    name: string;
    description: string;
    created_at: string;
    updated_at: string;
}

export interface ApiKTagAddRelationRequestJSON
{
  id: string
  k_tag: ApiKTagJSON;
  requester: ApiAccountJSON;
  request_status: number; // 0: pending, 1: accepted, 2: rejected
}

export interface ApiKTagDeleteRelationRequestJSON
{
  id: string
  k_tag_realation: ApiKTagRelationJSON
  requester: ApiAccountJSON;
  request_status: number; // 0: pending, 1: accepted, 2: rejected
  k_tag: ApiKTagJSON;
  is_owned: boolean;

}

export interface ApiKTagRelationJSON
{
  id : string;
  status_id: string;
  name: string;
  requester_id: string;
  created_at: string;
  updated_at: string;
}
