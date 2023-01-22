export const idlFactory = ({ IDL }) => {
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
    'locked_tokens' : IDL.Int,
    'delay' : IDL.Int,
  });
  const Proposal = IDL.Record({
    'id' : IDL.Int,
    'principal' : IDL.Principal,
    'vote_yes' : IDL.Nat,
    'text' : IDL.Text,
    'vote_no' : IDL.Nat,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Text, 'err' : IDL.Text });
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
    'get_neuron' : IDL.Func([IDL.Int], [IDL.Opt(Neuron)], ['query']),
    'get_principal' : IDL.Func([], [IDL.Principal], []),
    'get_proposal' : IDL.Func([IDL.Int], [IDL.Opt(Proposal)], ['query']),
    'lock_neuron' : IDL.Func([IDL.Nat, IDL.Int], [Result], []),
    'set_neuron_dissolving' : IDL.Func([IDL.Int, IDL.Int], [Result], []),
    'submit_proposal' : IDL.Func(
        [IDL.Text],
        [IDL.Variant({ 'Ok' : Proposal, 'Err' : IDL.Text })],
        [],
      ),
    'vote' : IDL.Func(
        [IDL.Int, IDL.Bool],
        [IDL.Variant({ 'Ok' : IDL.Tuple(IDL.Nat, IDL.Nat), 'Err' : IDL.Text })],
        [],
      ),
  });
  return Dao;
};
export const init = ({ IDL }) => { return []; };
