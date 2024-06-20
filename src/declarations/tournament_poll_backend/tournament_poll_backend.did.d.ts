import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Match {
  'id' : bigint,
  'status' : string,
  'result' : [] | [{ 'winner' : Principal, 'score' : string }],
  'participants' : Array<Principal>,
}
export type Time = bigint;
export interface Tournament {
  'id' : bigint,
  'participants' : Array<Principal>,
  'name' : string,
  'isActive' : boolean,
  'expirationDate' : Time,
  'prizePool' : string,
  'startDate' : Time,
}
export interface _SERVICE {
  'adminUpdateMatchResult' : ActorMethod<[bigint, Principal, string], boolean>,
  'closeRegistration' : ActorMethod<[bigint], boolean>,
  'confirmParticipation' : ActorMethod<[bigint], boolean>,
  'createTournament' : ActorMethod<[string, Time, string, Time], bigint>,
  'disputeMatch' : ActorMethod<[bigint, string], boolean>,
  'forfeitMatch' : ActorMethod<[bigint, Principal], boolean>,
  'getActiveTournaments' : ActorMethod<[], Array<Tournament>>,
  'getAllTournaments' : ActorMethod<[], Array<Tournament>>,
  'getInactiveTournaments' : ActorMethod<[], Array<Tournament>>,
  'getRegisteredUsers' : ActorMethod<
    [bigint],
    Array<
      {
        'elo' : bigint,
        'principal' : Principal,
        'username' : string,
        'avatarId' : bigint,
      }
    >
  >,
  'getTournamentBracket' : ActorMethod<[bigint], { 'matches' : Array<Match> }>,
  'joinTournament' : ActorMethod<[bigint], boolean>,
  'manageDispute' : ActorMethod<[bigint, string], boolean>,
  'registerUser' : ActorMethod<[], boolean>,
  'resolveDispute' : ActorMethod<[bigint, string], boolean>,
  'submitFeedback' : ActorMethod<[bigint, string], boolean>,
  'submitMatchResult' : ActorMethod<[bigint, Principal, string], boolean>,
  'updateBracket' : ActorMethod<[bigint], boolean>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
