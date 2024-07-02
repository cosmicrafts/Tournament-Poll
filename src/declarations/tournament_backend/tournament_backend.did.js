export const idlFactory = ({ IDL }) => {
  const Time = IDL.Int;
  const Tournament = IDL.Record({
    'id' : IDL.Nat,
    'participants' : IDL.Vec(IDL.Principal),
    'name' : IDL.Text,
    'isActive' : IDL.Bool,
    'expirationDate' : Time,
    'registeredParticipants' : IDL.Vec(IDL.Principal),
    'bracketCreated' : IDL.Bool,
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
    'tournamentId' : IDL.Nat,
  });
  return IDL.Service({
    'adminUpdateMatch' : IDL.Func([IDL.Nat, IDL.Text], [IDL.Bool], []),
    'createTournament' : IDL.Func(
        [IDL.Text, Time, IDL.Text, Time],
        [IDL.Nat],
        [],
      ),
    'deleteAllTournaments' : IDL.Func([], [IDL.Bool], []),
    'disputeMatch' : IDL.Func([IDL.Nat, IDL.Text], [IDL.Bool], []),
    'getActiveTournaments' : IDL.Func([], [IDL.Vec(Tournament)], ['query']),
    'getAllTournaments' : IDL.Func([], [IDL.Vec(Tournament)], ['query']),
    'getInactiveTournaments' : IDL.Func([], [IDL.Vec(Tournament)], ['query']),
    'getRegisteredUsers' : IDL.Func(
        [IDL.Nat],
        [IDL.Vec(IDL.Principal)],
        ['query'],
      ),
    'getTournamentBracket' : IDL.Func(
        [IDL.Nat],
        [IDL.Record({ 'matches' : IDL.Vec(Match) })],
        ['query'],
      ),
    'joinTournament' : IDL.Func([IDL.Nat], [IDL.Bool], []),
    'submitFeedback' : IDL.Func([IDL.Nat, IDL.Text], [IDL.Bool], []),
    'submitMatchResult' : IDL.Func([IDL.Nat, IDL.Text], [IDL.Bool], []),
    'updateBracket' : IDL.Func([IDL.Nat], [IDL.Bool], []),
    'updateBracketAfterMatchUpdate' : IDL.Func(
        [IDL.Nat, IDL.Nat, IDL.Principal],
        [IDL.Bool],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
