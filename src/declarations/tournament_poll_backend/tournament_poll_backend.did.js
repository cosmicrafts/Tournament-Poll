export const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
  const Tournament = IDL.Record({
    'id' : IDL.Nat,
    'participants' : IDL.Vec(IDL.Principal),
    'name' : IDL.Text,
    'isActive' : IDL.Bool,
    'expirationDate' : Time,
    'prizePool' : IDL.Text,
    'startDate' : Time,
  });
  const Match = IDL.Record({
    'id' : IDL.Nat,
    'status' : IDL.Text,
    'result' : IDL.Opt(
      IDL.Record({ 'winner' : IDL.Principal, 'score' : IDL.Text })
    ),
    'participants' : IDL.Vec(IDL.Principal),
  });
  return IDL.Service({
    'adminUpdateMatchResult' : IDL.Func(
        [IDL.Nat, IDL.Principal, IDL.Text],
        [IDL.Bool],
        [],
      ),
    'closeRegistration' : IDL.Func([IDL.Nat], [IDL.Bool], []),
    'confirmParticipation' : IDL.Func([IDL.Nat], [IDL.Bool], []),
    'createTournament' : IDL.Func(
        [IDL.Text, Time, IDL.Text, Time],
        [IDL.Nat],
        [],
      ),
    'disputeMatch' : IDL.Func([IDL.Nat, IDL.Text], [IDL.Bool], []),
    'forfeitMatch' : IDL.Func([IDL.Nat, IDL.Principal], [IDL.Bool], []),
    'getActiveTournaments' : IDL.Func([], [IDL.Vec(Tournament)], ['query']),
    'getAllTournaments' : IDL.Func([], [IDL.Vec(Tournament)], ['query']),
    'getInactiveTournaments' : IDL.Func([], [IDL.Vec(Tournament)], ['query']),
    'getRegisteredUsers' : IDL.Func(
        [IDL.Nat],
        [
          IDL.Vec(
            IDL.Record({
              'elo' : IDL.Nat,
              'principal' : IDL.Principal,
              'username' : IDL.Text,
              'avatarId' : IDL.Nat,
            })
          ),
        ],
        ['query'],
      ),
    'getTournamentBracket' : IDL.Func(
        [IDL.Nat],
        [IDL.Record({ 'matches' : IDL.Vec(Match) })],
        ['query'],
      ),
    'joinTournament' : IDL.Func([IDL.Nat], [IDL.Bool], []),
    'manageDispute' : IDL.Func([IDL.Nat, IDL.Text], [IDL.Bool], []),
    'registerUser' : IDL.Func([], [IDL.Bool], []),
    'resolveDispute' : IDL.Func([IDL.Nat, IDL.Text], [IDL.Bool], []),
    'submitFeedback' : IDL.Func([IDL.Nat, IDL.Text], [IDL.Bool], []),
    'submitMatchResult' : IDL.Func(
        [IDL.Nat, IDL.Principal, IDL.Text],
        [IDL.Bool],
        [],
      ),
    'updateBracket' : IDL.Func([IDL.Nat], [IDL.Bool], []),
  });
};
export const init = ({ IDL }) => { return []; };
