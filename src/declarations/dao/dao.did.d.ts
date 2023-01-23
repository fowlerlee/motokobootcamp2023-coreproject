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
  'get_neuron' : ActorMethod<[bigint], [] | [Neuron]>,
  'get_principal' : ActorMethod<[], Principal>,
  'get_proposal' : ActorMethod<[bigint], [] | [Proposal]>,
  'lock_neuron' : ActorMethod<[bigint, bigint], Result>,
  'set_neuron_dissolving' : ActorMethod<[bigint], Result>,
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
  'principal' : Principal,
  'vote_yes' : bigint,
  'text' : string,
  'vote_no' : bigint,
}
export type Result = { 'ok' : string } |
  { 'err' : string };
export type Subaccount = Uint8Array;
export interface _SERVICE extends Dao {}
