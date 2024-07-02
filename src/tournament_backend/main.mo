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
        registeredParticipants: [Principal]; // New field to store registered participants
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
        // Check if the tournament exists
        if (tournamentId >= tournaments.size()) {
            return false;
        };

        let tournament = tournaments[tournamentId];

        // Check if the user is already a participant
        if (Array.indexOf<Principal>(caller, tournament.participants, func (a: Principal, b: Principal) : Bool { a == b }) != null) {
            return false;
        };

        // Add the user to the tournament participants
        var updatedParticipants = Buffer.Buffer<Principal>(tournament.participants.size() + 1);
        for (participant in tournament.participants.vals()) {
            updatedParticipants.add(participant);
        };
        updatedParticipants.add(caller);

        // Add the user to the registered participants if bracket is not created
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
        // Find the match with the given ID
        let matchOpt = Array.find<Match>(matches, func (m: Match) : Bool { m.id == matchId });
        switch (matchOpt) {
            case (?match) {
                // Ensure the caller is a participant in the match
                let isParticipant = Array.find<Principal>(match.participants, func (p: Principal) : Bool { p == caller }) != null;
                if (not isParticipant) {
                    return false;
                };

                // Update the match with the result
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
        // Check if the match exists
        let matchExists = Array.find(matches, func (m: Match) : Bool { m.id == matchId }) != null;
        if (not matchExists) {
            return false;
        };

        // Add the dispute to the disputes array
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

            // Handle progress to next round or declare winner
            var foundTournament: ?Tournament = null;
            for (t in tournaments.vals()) {
                if (t.id == match.tournamentId) {
                    foundTournament := ?t;
                }
            };

            switch (foundTournament) {
                case (?t) {
                    var allMatchesVerified = true;
                    var winners = Buffer.Buffer<Principal>(0);
                    for (m in matches.vals()) {
                        if (m.tournamentId == t.id) {
                            if (m.status != "verified") {
                                allMatchesVerified := false;
                            } else {
                                switch (m.result) {
                                    case (?res) {
                                        winners.add(res.winner);
                                    };
                                    case null {};
                                }
                            }
                        }
                    };

                    if (allMatchesVerified) {
                        if (winners.size() == 1) {
                            let updatedTournaments = Buffer.Buffer<Tournament>(tournaments.size());
                            for (tournament in tournaments.vals()) {
                                if (tournament.id == t.id) {
                                    updatedTournaments.add({
                                        id = tournament.id;
                                        name = tournament.name;
                                        startDate = tournament.startDate;
                                        prizePool = tournament.prizePool;
                                        expirationDate = tournament.expirationDate;
                                        participants = tournament.participants;
                                        registeredParticipants = tournament.registeredParticipants;
                                        isActive = false; // We have a champion
                                        bracketCreated = tournament.bracketCreated
                                    });
                                } else {
                                    updatedTournaments.add(tournament);
                                }
                            };
                            tournaments := Buffer.toArray(updatedTournaments);
                        } else {
                            // Create next round
                            let nextParticipants = Buffer.toArray(winners);
                            let updatedTournaments = Buffer.Buffer<Tournament>(tournaments.size());
                            for (tournament in tournaments.vals()) {
                                if (tournament.id == t.id) {
                                    updatedTournaments.add({
                                        id = tournament.id;
                                        name = tournament.name;
                                        startDate = tournament.startDate;
                                        prizePool = tournament.prizePool;
                                        expirationDate = tournament.expirationDate;
                                        participants = nextParticipants;
                                        registeredParticipants = tournament.registeredParticipants;
                                        isActive = true;
                                        bracketCreated = tournament.bracketCreated
                                    });
                                } else {
                                    updatedTournaments.add(tournament);
                                }
                            };
                            tournaments := Buffer.toArray(updatedTournaments);
                            ignore await updateBracket(t.id);
                        }
                    }
                };
                case null {};
            };

            return true;
        };
        case null {
            return false;
        };
    }
};


    // Calculate the base-2 logarithm of a number
    func log2(x: Nat): Nat {
        var result = 0;
        var value = x;
        while (value > 1) {
            value /= 2;
            result += 1;
        };
        return result;
    };

    public shared func updateBracket(tournamentId: Nat) : async Bool {
    if (tournamentId >= tournaments.size()) {
        Debug.print("Tournament does not exist.");
        return false;
    };

    var tournament = tournaments[tournamentId];
    if (tournament.bracketCreated) {
        Debug.print("Bracket already created.");
        return false;
    };

    let participants = tournament.participants;

    // Close registration
    let updatedTournament = {
        id = tournament.id;
        name = tournament.name;
        startDate = tournament.startDate;
        prizePool = tournament.prizePool;
        expirationDate = tournament.expirationDate;
        participants = tournament.participants;
        registeredParticipants = tournament.registeredParticipants;
        isActive = false;
        bracketCreated = true
    };

    tournaments := Array.tabulate(tournaments.size(), func(i: Nat): Tournament {
        if (i == tournamentId) {
            updatedTournament
        } else {
            tournaments[i]
        }
    });

    // Obtain a fresh blob of entropy
    let entropy = await Random.blob();
    let random = Random.Finite(entropy);

    // Shuffle participants and byes
    var totalParticipants = 1;
    while (totalParticipants < participants.size()) {
        totalParticipants *= 2;
    };
    let byesCount = Nat.sub(totalParticipants, participants.size());
    var allParticipants = Buffer.Buffer<Principal>(totalParticipants);
    for (p in participants.vals()) {
        allParticipants.add(p);
    };
    for (i in Iter.range(0, byesCount - 1)) {
        allParticipants.add(Principal.fromText("2vxsx-fae"));
    };

    // Shuffle all participants and byes together
    var shuffledParticipants = Array.thaw<Principal>(Buffer.toArray(allParticipants));
    var i = shuffledParticipants.size();
    while (i > 1) {
        i -= 1;
        let j = switch (random.range(32)) {
            case (?value) { value % (i + 1) };
            case null { i }
        };
        let temp = shuffledParticipants[i];
        shuffledParticipants[i] := shuffledParticipants[j];
        shuffledParticipants[j] := temp;
    };

    Debug.print("Total participants after adjustment: " # Nat.toText(totalParticipants));

    // Create initial round matches
    let roundMatches = Buffer.Buffer<Match>(0);
    var matchId = 0;
    for (i in Iter.range(0, totalParticipants / 2 - 1)) {
        let p1 = shuffledParticipants[i * 2];
        let p2 = shuffledParticipants[i * 2 + 1];
        if (p1 == Principal.fromText("2vxsx-fae") or p2 == Principal.fromText("2vxsx-fae")) {
            // Ensure byes are matched with actual participants if possible
            if (p1 == Principal.fromText("2vxsx-fae")) {
                roundMatches.add({
                    id = matchId;
                    tournamentId = tournamentId;
                    participants = [p2, p1];
                    result = ?{winner = p2; score = "bye"};
                    status = "verified";
                });
            } else {
                roundMatches.add({
                    id = matchId;
                    tournamentId = tournamentId;
                    participants = [p1, p2];
                    result = ?{winner = p1; score = "bye"};
                    status = "verified";
                });
            }
        } else {
            roundMatches.add({
                id = matchId;
                tournamentId = tournamentId;
                participants = [p1, p2];
                result = null;
                status = "scheduled";
            });
        };
        matchId += 1;
    };

    // Function to recursively create matches for all rounds filled with "bye"
    func createAllRounds(totalRounds: Nat, currentRound: Nat, matchId: Nat) : Buffer.Buffer<Match> {
        let newMatches = Buffer.Buffer<Match>(0);
        if (currentRound >= totalRounds) {
            return newMatches;
        };
        let numMatches = (totalParticipants / (2 ** (currentRound + 1)));
        for (i in Iter.range(0, numMatches - 1)) {
            newMatches.add({
                id = matchId + i;
                tournamentId = tournamentId;
                participants = [Principal.fromText("2vxsx-fae"), Principal.fromText("2vxsx-fae")];
                result = null;
                status = "scheduled";
            });
        };
        let nextRoundMatches = createAllRounds(totalRounds, currentRound + 1, matchId + numMatches);
        for (match in nextRoundMatches.vals()) {
            newMatches.add(match);
        };
        return newMatches;
    };

    let totalRounds = log2(totalParticipants);
    Debug.print("Total rounds: " # Nat.toText(totalRounds));
    let subsequentRounds = createAllRounds(totalRounds, 1, matchId);

    // Update the stable variable matches
    var updatedMatches = Buffer.Buffer<Match>(matches.size() + roundMatches.size() + subsequentRounds.size());
    for (match in matches.vals()) {
        updatedMatches.add(match);
    };
    for (newMatch in roundMatches.vals()) {
        updatedMatches.add(newMatch);
    };
    for (subsequentMatch in subsequentRounds.vals()) {
        updatedMatches.add(subsequentMatch);
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
