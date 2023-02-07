export const idlFactory = ({ IDL }) => {
  const List = IDL.Rec();
  const Subaccount = IDL.Vec(IDL.Nat8);
  const Account = IDL.Record({
    'owner' : IDL.Principal,
    'subaccount' : IDL.Opt(Subaccount),
  });
  const Neuron = IDL.Record({
    'id' : IDL.Principal,
    'state' : IDL.Variant({
      'locked' : IDL.Null,
      'dissolved' : IDL.Null,
      'dissolving' : IDL.Null,
    }),
    'account' : Account,
    'locked_tokens' : IDL.Nat,
    'delay' : IDL.Int,
  });
  const Tokens = IDL.Nat;
  List.fill(IDL.Opt(IDL.Tuple(IDL.Principal, List)));
  const ProposalState = IDL.Variant({
    'open' : IDL.Null,
    'rejected' : IDL.Null,
    'accepted' : IDL.Null,
    'failed' : IDL.Text,
    'succeeded' : IDL.Null,
  });
  const ProposalPayload = IDL.Record({
    'method' : IDL.Text,
    'canister_id' : IDL.Principal,
    'message' : IDL.Vec(IDL.Nat8),
  });
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'votes_no' : Tokens,
    'voters' : List,
    'state' : ProposalState,
    'timestamp' : IDL.Int,
    'proposer' : IDL.Principal,
    'votes_yes' : Tokens,
    'payload' : ProposalPayload,
  });
  const canister_id = IDL.Principal;
  const UserNumber = IDL.Nat64;
  const FrontendHostname = IDL.Text;
  const Result__1 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
  const Result = IDL.Variant({
    'ok' : IDL.Tuple(IDL.Nat, IDL.Nat),
    'err' : IDL.Text,
  });
  const Dao = IDL.Service({
    'execute_accepted_proposals' : IDL.Func([], [], []),
    'get_all_neurons' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Int, Neuron))],
        ['query'],
      ),
    'get_all_proposals' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Int, Proposal))],
        ['query'],
      ),
    'get_canister_status' : IDL.Func(
        [canister_id],
        [
          IDL.Record({
            'memory_size' : IDL.Nat,
            'cycles' : IDL.Nat,
            'idle_cycles_burned_per_day' : IDL.Nat,
          }),
        ],
        [],
      ),
    'get_neuron' : IDL.Func([IDL.Int], [IDL.Opt(Neuron)], ['query']),
    'get_principal' : IDL.Func([], [IDL.Principal], []),
    'get_principal_from_II' : IDL.Func(
        [UserNumber, FrontendHostname],
        [IDL.Principal],
        [],
      ),
    'get_proposal' : IDL.Func([IDL.Int], [IDL.Opt(Proposal)], ['query']),
    'lock_neuron' : IDL.Func([IDL.Nat, IDL.Int], [Result__1], []),
    'set_neuron_dissolving' : IDL.Func([IDL.Int], [], []),
    'submit_proposal' : IDL.Func(
        [ProposalPayload],
        [IDL.Variant({ 'Ok' : Proposal, 'Err' : IDL.Text })],
        [],
      ),
    'transfer_to_user_account' : IDL.Func([Neuron], [Result_1], []),
    'vote' : IDL.Func([IDL.Int, IDL.Bool], [Result], []),
  });
  return Dao;
};
export const init = ({ IDL }) => { return []; };
