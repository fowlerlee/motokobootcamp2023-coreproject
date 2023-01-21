import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Dex {
  'get_all_proposals' : ActorMethod<[], Array<[bigint, Proposal]>>,
  'get_principal' : ActorMethod<[], Principal>,
  'get_proposal' : ActorMethod<[bigint], [] | [Proposal]>,
  'submit_proposal' : ActorMethod<
    [string],
    { 'Ok' : Proposal } |
      { 'Err' : string }
  >,
  'vote' : ActorMethod<
    [bigint, boolean],
    { 'Ok' : [bigint, bigint] } |
      { 'Err' : string }
  >,
}
export interface Proposal {
  'id' : bigint,
  'principal' : Principal,
  'vote_yes' : bigint,
  'text' : string,
  'vote_no' : bigint,
}
export interface _SERVICE extends Dex {}
