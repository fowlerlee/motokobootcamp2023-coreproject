export const idlFactory = ({ IDL }) => {
  const Proposal = IDL.Record({
    'id' : IDL.Int,
    'principal' : IDL.Principal,
    'vote_for' : IDL.Nat,
    'text' : IDL.Text,
    'vote_against' : IDL.Nat,
  });
  return IDL.Service({
    'get_all_proposals' : IDL.Func(
        [],
        [IDL.Vec(IDL.Tuple(IDL.Int, Proposal))],
        ['query'],
      ),
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
};
export const init = ({ IDL }) => { return []; };
