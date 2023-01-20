import Principal "mo:base/Principal";
import T "./Types";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";





actor {

    
    
    private var proposals = HashMap.HashMap<Principal, List.List<T.Proposal>>(1, Principal.equal, Principal.hash);
    private var users = HashMap.HashMap<Principal, T.Account>(10, Principal.equal, Principal.hash);
    private stable var number_of_proposals : Nat = 1;
    private stable var stable_proposals: [(Principal, List.List<T.Proposal>)] = [];

    private func is_user_registered(principal: Principal): Bool {
        switch(users.get(principal)) {
            case(?some) { true };
            case(_) { false };
        };
    };

    public shared({caller}) func submit_proposal(this_payload : Text) : async Result.Result<T.Proposal, Text> {
        // assert not Principal.isAnonymous(caller);
        // assert is_user_registered(caller);
//   public type Proposal = {
//     id : Nat;
//     votes_no : Tokens;
//     voters : List.List<Principal>;
//     state : ProposalState;
//     timestamp : Int;
//     proposer : Principal;
//     votes_yes : Tokens;
//     payload : ProposalPayload;
//   };
        return #err("Not implemented yet");
    };

    public shared({caller}) func vote(proposal_id : Int, yes_or_no : Bool) : async {#Ok : (Nat, Nat); #Err : Text} {
        return #Err("Not implemented yet");
    };

    public query func get_proposal(id : Int) : async ?T.Proposal {
        return null
    };
    
    public query func get_all_proposals() : async [(Int, T.Proposal)] {
        return []
    };

    system func preupgrade() {
        Debug.print("Starting pre-upgrade hook...");
        stable_proposals := Iter.toArray(proposals.entries());
        // stable_users := UserStore.serializeAll(users);
        Debug.print("pre-upgrade finished.");
    };

    // The work required after a canister upgrade ends.
    // See [nextNoteId], [stable_notesByUser], [stable_users]
    system func postupgrade() {
        Debug.print("Starting post-upgrade hook...");
        proposals := HashMap.fromIter<Principal, List.List<T.Proposal>>(
            stable_proposals.vals(), stable_proposals.size(), Principal.equal, Principal.hash);

        // users := UserStore.deserialize(stable_users, stable_notesByUser.size());
        stable_proposals := [];
        Debug.print("post-upgrade finished.");
    };

};