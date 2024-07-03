import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Match {
  'id' : bigint,
  'status' : string,
  'result' : [] | [{ 'winner' : Principal, 'score' : string }],
  'participants' : Array<Principal>,
  'nextMatchId' : [] | [bigint],
  'tournamentId' : bigint,
}
export type Time = bigint;
export interface Tournament {
  'id' : bigint,
  'participants' : Array<Principal>,
  'name' : string,
  'isActive' : boolean,
  'expirationDate' : Time,
  'matchCounter' : bigint,
  'registeredParticipants' : Array<Principal>,
  'bracketCreated' : boolean,
  'prizePool' : string,
  'startDate' : Time,
}
export interface _SERVICE {
  'adminUpdateMatch' : ActorMethod<[bigint, bigint, bigint, string], boolean>,
  'createTournament' : ActorMethod<[string, Time, string, Time], bigint>,
  'deleteAllTournaments' : ActorMethod<[], boolean>,
  'disputeMatch' : ActorMethod<[bigint, bigint, string], boolean>,
  'getActiveTournaments' : ActorMethod<[], Array<Tournament>>,
  'getAllTournaments' : ActorMethod<[], Array<Tournament>>,
  'getInactiveTournaments' : ActorMethod<[], Array<Tournament>>,
  'getRegisteredUsers' : ActorMethod<[bigint], Array<Principal>>,
  'getTournamentBracket' : ActorMethod<[bigint], { 'matches' : Array<Match> }>,
  'joinTournament' : ActorMethod<[bigint], boolean>,
  'submitFeedback' : ActorMethod<[bigint, string], boolean>,
  'submitMatchResult' : ActorMethod<[bigint, bigint, string], boolean>,
  'updateBracket' : ActorMethod<[bigint], boolean>,
  'updateBracketAfterMatchUpdate' : ActorMethod<
    [bigint, bigint, Principal],
    undefined
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
