import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Account {
  'owner' : Principal,
  'subaccount' : [] | [Subaccount],
}
export interface Dao {
  'execute_accepted_proposals' : ActorMethod<[], undefined>,
  'get_all_neurons' : ActorMethod<[], Array<[bigint, Neuron]>>,
  'get_all_proposals' : ActorMethod<[], Array<[bigint, Proposal]>>,
  'get_canister_status' : ActorMethod<
    [canister_id],
    {
      'memory_size' : bigint,
      'cycles' : bigint,
      'idle_cycles_burned_per_day' : bigint,
    }
  >,
  'get_neuron' : ActorMethod<[bigint], [] | [Neuron]>,
  'get_principal' : ActorMethod<[], Principal>,
  'get_principal_from_II' : ActorMethod<
    [UserNumber, FrontendHostname],
    Principal
  >,
  'get_proposal' : ActorMethod<[bigint], [] | [Proposal]>,
  'lock_neuron' : ActorMethod<[bigint, bigint], Result__1>,
  'set_neuron_dissolving' : ActorMethod<[bigint], undefined>,
  'submit_proposal' : ActorMethod<
    [ProposalPayload],
    { 'Ok' : Proposal } |
      { 'Err' : string }
  >,
  'transfer_to_user_account' : ActorMethod<[Neuron], Result_1>,
  'vote' : ActorMethod<[bigint, boolean], Result>,
}
export type FrontendHostname = string;
export type List = [] | [[Principal, List]];
export interface Neuron {
  'id' : Principal,
  'state' : { 'locked' : null } |
    { 'dissolved' : null } |
    { 'dissolving' : null },
  'account' : Account,
  'locked_tokens' : bigint,
  'delay' : bigint,
}
export interface Proposal {
  'id' : bigint,
  'votes_no' : Tokens,
  'voters' : List,
  'state' : ProposalState,
  'timestamp' : bigint,
  'proposer' : Principal,
  'votes_yes' : Tokens,
  'payload' : ProposalPayload,
}
export interface ProposalPayload {
  'method' : string,
  'canister_id' : Principal,
  'message' : Uint8Array,
}
export type ProposalState = { 'open' : null } |
  { 'rejected' : null } |
  { 'accepted' : null } |
  { 'failed' : string } |
  { 'succeeded' : null };
export type Result = { 'ok' : [bigint, bigint] } |
  { 'err' : string };
export type Result_1 = { 'ok' : string } |
  { 'err' : string };
export type Result__1 = { 'ok' : string } |
  { 'err' : string };
export type Subaccount = Uint8Array;
export type Tokens = bigint;
export type UserNumber = bigint;
export type canister_id = Principal;
export interface _SERVICE extends Dao {}
