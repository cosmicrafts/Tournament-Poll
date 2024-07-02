import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Random "mo:base/Random";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";

actor Backend {
    stable var tournaments: [Tournament] = [];
    stable var matches: [Match] = [];
    stable var feedback: [{ principal: Principal; tournamentId: Nat; feedback: Text }] = [];
    stable var disputes: [{ principal: Principal; matchId: Nat; reason: Text; status: Text }] = [];

    type Tournament = {
        id: Nat;
        name: Text;
        startDate: Time.Time;
        prizePool: Text;
        expirationDate: Time.Time;
        participants: [Principal];
        registeredParticipants: [Principal];
        isActive: Bool;
        bracketCreated: Bool;
    };

    type Match = {
        id: Nat;
        tournamentId: Nat;
        participants: [Principal];
        result: ?{winner: Principal; score: Text};
        status: Text;
    };

    public shared ({caller}) func createTournament(name: Text, startDate: Time.Time, prizePool: Text, expirationDate: Time.Time) : async Nat {
        if (caller != Principal.fromText("vam5o-bdiga-izgux-6cjaz-53tck-eezzo-fezki-t2sh6-xefok-dkdx7-pae") and
            caller != Principal.fromText("bdycp-b54e6-fvsng-ouies-a6zfm-khbnh-wcq3j-pv7qt-gywe2-em245-3ae")) {
            return 0;
        };

        let id = tournaments.size();
        let buffer = Buffer.Buffer<Tournament>(tournaments.size() + 1);
        for (tournament in tournaments.vals()) {
            buffer.add(tournament);
        };
        buffer.add({
            id = id;
            name = name;
            startDate = startDate;
            prizePool = prizePool;
            expirationDate = expirationDate;
            participants = [];
            registeredParticipants = [];
            isActive = true;
            bracketCreated = false
        });
        tournaments := Buffer.toArray(buffer);
        return id;
    };

    public shared ({caller}) func joinTournament(tournamentId: Nat) : async Bool {
        if (tournamentId >= tournaments.size()) {
            return false;
        };

        let tournament = tournaments[tournamentId];

        if (Array.indexOf<Principal>(caller, tournament.participants, func (a: Principal, b: Principal) : Bool { a == b }) != null) {
            return false;
        };

        var updatedParticipants = Buffer.Buffer<Principal>(tournament.participants.size() + 1);
        for (participant in tournament.participants.vals()) {
            updatedParticipants.add(participant);
        };
        updatedParticipants.add(caller);

        var updatedRegisteredParticipants = Buffer.Buffer<Principal>(tournament.registeredParticipants.size() + 1);
        for (participant in tournament.registeredParticipants.vals()) {
            updatedRegisteredParticipants.add(participant);
        };
        updatedRegisteredParticipants.add(caller);

        let updatedTournament = {
            id = tournament.id;
            name = tournament.name;
            startDate = tournament.startDate;
            prizePool = tournament.prizePool;
            expirationDate = tournament.expirationDate;
            participants = Buffer.toArray(updatedParticipants);
            registeredParticipants = Buffer.toArray(updatedRegisteredParticipants);
            isActive = tournament.isActive;
            bracketCreated = tournament.bracketCreated
        };

        tournaments := Array.tabulate(tournaments.size(), func(i: Nat): Tournament {
            if (i == tournamentId) {
                updatedTournament
            } else {
                tournaments[i]
            }
        });

        return true;
    };

    public query func getRegisteredUsers(tournamentId: Nat) : async [Principal] {
        if (tournamentId >= tournaments.size()) {
            return [];
        };

        let tournament: Tournament = tournaments[tournamentId];
        return tournament.registeredParticipants;
    };

    public shared ({caller}) func submitFeedback(_tournamentId: Nat, feedbackText: Text) : async Bool {
        let newFeedback = Buffer.Buffer<{principal: Principal; tournamentId: Nat; feedback: Text}>(feedback.size() + 1);
        for (entry in feedback.vals()) {
            newFeedback.add(entry);
        };
        newFeedback.add({principal = caller; tournamentId = _tournamentId; feedback = feedbackText});
        feedback := Buffer.toArray(newFeedback);
        return true;
    };

    public shared ({caller}) func submitMatchResult(matchId: Nat, score: Text) : async Bool {
        let matchOpt = Array.find<Match>(matches, func (m: Match) : Bool { m.id == matchId });
        switch (matchOpt) {
            case (?match) {
                let isParticipant = Array.find<Principal>(match.participants, func (p: Principal) : Bool { p == caller }) != null;
                if (not isParticipant) {
                    return false;
                };

                var updatedMatches = Buffer.Buffer<Match>(matches.size());
                for (m in matches.vals()) {
                    if (m.id == matchId) {
                        updatedMatches.add({
                            id = m.id;
                            tournamentId = m.tournamentId;
                            participants = m.participants;
                            result = ?{winner = caller; score = score};
                            status = "pending verification";
                        });
                    } else {
                        updatedMatches.add(m);
                    }
                };
                matches := Buffer.toArray(updatedMatches);
                return true;
            };
            case null {
                return false;
            };
        }
    };

    public shared ({caller}) func disputeMatch(matchId: Nat, reason: Text) : async Bool {
        let matchExists = Array.find(matches, func (m: Match) : Bool { m.id == matchId }) != null;
        if (not matchExists) {
            return false;
        };

        let newDispute = { principal = caller; matchId = matchId; reason = reason; status = "pending" };
        let updatedDisputes = Buffer.Buffer<{ principal: Principal; matchId: Nat; reason: Text; status: Text }>(disputes.size() + 1);
        for (dispute in disputes.vals()) {
            updatedDisputes.add(dispute);
        };
        updatedDisputes.add(newDispute);
        disputes := Buffer.toArray(updatedDisputes);

        return true;
    };

    public shared ({caller}) func adminUpdateMatch(matchId: Nat, score: Text) : async Bool {
        if (caller != Principal.fromText("vam5o-bdiga-izgux-6cjaz-53tck-eezzo-fezki-t2sh6-xefok-dkdx7-pae") and
            caller != Principal.fromText("bdycp-b54e6-fvsng-ouies-a6zfm-khbnh-wcq3j-pv7qt-gywe2-em245-3ae")) {
            return false;
        };

        let matchIndex = Array.find<Match>(matches, func (m: Match) : Bool { m.id == matchId });
        switch (matchIndex) {
            case (?match) {
                var updatedMatches = Buffer.Buffer<Match>(matches.size());
                for (m in matches.vals()) {
                    if (m.id == matchId) {
                        updatedMatches.add({
                            id = m.id;
                            tournamentId = m.tournamentId;
                            participants = m.participants;
                            result = ?{winner = m.participants[0]; score = score}; // Assuming the winner is the first participant
                            status = "verified";
                        });
                    } else {
                        updatedMatches.add(m);
                    }
                };
                matches := Buffer.toArray(updatedMatches);

                // Update the bracket after verifying the match result
                ignore await updateBracket(match.tournamentId);

                return true;
            };
            case null {
                return false;
            };
        }
    };

    // Helper function to update the bracket after a match result is verified
    public shared func updateBracket(tournamentId: Nat) : async Bool {
        if (tournamentId >= tournaments.size()) {
            Debug.print("Tournament does not exist.");
            return false;
        };

        var tournament = tournaments[tournamentId];
        var winnersBuffer = Buffer.Buffer<Principal>(0);

        // Gather winners from verified matches of the current round
        for (m in matches.vals()) {
            if (m.tournamentId == tournamentId and m.status == "verified") {
                switch (m.result) {
                    case (?res) {
                        winnersBuffer.add(res.winner);
                    };
                    case null {};
                }
            }
        };

        let winners = Buffer.toArray(winnersBuffer);

        // Calculate the next round
        let nextRoundMatches = Buffer.Buffer<Match>(0);
        var matchId = matches.size();
        var remainingParticipants = winners.size();

        while (remainingParticipants > 1) {
            for (i in Iter.range(0, remainingParticipants / 2 - 1)) {
                let p1 = winners[i * 2];
                let p2 = winners[i * 2 + 1];
                nextRoundMatches.add({
                    id = matchId;
                    tournamentId = tournamentId;
                    participants = [p1, p2];
                    result = null;
                    status = "scheduled";
                });
                matchId += 1;
            };
            remainingParticipants /= 2;
        };

        // Update the stable variable matches
        var updatedMatches = Buffer.Buffer<Match>(matches.size() + nextRoundMatches.size());
        for (match in matches.vals()) {
            updatedMatches.add(match);
        };
        for (newMatch in nextRoundMatches.vals()) {
            updatedMatches.add(newMatch);
        };
        matches := Buffer.toArray(updatedMatches);

        return true;
    };

    public query func getActiveTournaments() : async [Tournament] {
        return Array.filter<Tournament>(tournaments, func (t: Tournament) : Bool { t.isActive });
    };

    public query func getInactiveTournaments() : async [Tournament] {
        return Array.filter<Tournament>(tournaments, func (t: Tournament) : Bool { not t.isActive });
    };

    public query func getAllTournaments() : async [Tournament] {
        return tournaments;
    };

    public query func getTournamentBracket(tournamentId: Nat) : async {matches: [Match]} {
        return {
            matches = Array.filter<Match>(matches, func (m: Match) : Bool { m.tournamentId == tournamentId })
        };
    };

    public shared func deleteAllTournaments() : async Bool {
        tournaments := [];
        matches := [];
        return true;
    };
}
