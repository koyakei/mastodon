import type { Tag } from 'react-tag-autocomplete';

export interface KTag extends Tag {
  id: number;
  name: string;
  isOwned: boolean;
}

