export const idlFactory = ({ IDL }) => {
  const Proposal = IDL.Record({
    'id' : IDL.Int,
    'principal' : IDL.Principal,
    'vote_yes' : IDL.Nat,
    'text' : IDL.Text,
    'vote_no' : IDL.Nat,
  });
  const Dex = IDL.Service({
    'get_all_proposals' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Int, Proposal))],
        ['query'],
      ),
    'get_principal' : IDL.Func([], [IDL.Principal], []),
    'get_proposal' : IDL.Func([IDL.Int], [IDL.Opt(Proposal)], ['query']),
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
  return Dex;
};
export const init = ({ IDL }) => { return []; };
