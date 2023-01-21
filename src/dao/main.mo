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
import Time "mo:base/Time";

import Option "mo:base/Option";

shared(init_msg) actor class Dex() = this {

    type Proposal = {
        id : Int;
        text : Text;
        principal : Principal;
        vote_yes : Nat;
        vote_no : Nat
    };

    type Neuron = {
        id : Principal;
        locked_tokens : Int;
        state : { #locked; #dissolved; #dissolving };
        delay : Int
    };

    stable var proposalId : Int = 0;
    stable var neuronId : Nat = 0;
    stable var stable_store : [(Int, Proposal)] = [];
    stable var stable_neurons : [(Nat, Neuron)] = [];

    let all_neurons = HashMap.fromIter<Nat, Neuron>(stable_neurons.vals(), 10, Nat.equal, Hash.hash);
    let store = HashMap.fromIter<Int, Proposal>(stable_store.vals(), 10, Int.equal, Int.hash);

    public func get_principal() : async Principal {
        return Principal.fromActor(this);
    };

    public shared ({ caller }) func submit_proposal(this_payload : Text) : async {
        #Ok : Proposal;
        #Err : Text
    } {
        // assert not Principal.isAnonymous(caller);
        var prop : Proposal = {
            id = proposalId;
            text = this_payload;
            principal = caller;
            vote_yes = 0;
            vote_no = 0
        };

        store.put(proposalId, prop);
        proposalId += 1;
        return #Ok(prop)
    };

    public shared ({ caller }) func vote(proposal_id : Int, yes_or_no : Bool) : async {
        #Ok : (Nat, Nat);
        #Err : Text
    } {
        // assert not Principal.isAnonymous(caller);
        switch (store.get(proposal_id)) {
            case (null) {
                return #Err("No proposal with id " # Int.toText(proposal_id) # " exists")
            };
            case (?some) {
                var vote_yes : Nat = some.vote_yes;
                var vote_no : Nat = some.vote_no;
                if (yes_or_no) {
                    vote_yes := 1000
                } else {
                    vote_no := 1000
                };
                var prop : Proposal = {
                    id = some.id;
                    text = some.text;
                    principal = some.principal;
                    vote_yes;
                    vote_no
                };
                store.put(some.id, prop);

                return #Ok(prop.vote_yes, prop.vote_no)
            }
        }
    };

    public query func get_proposal(id : Int) : async ?Proposal {
        store.get(id)
    };

    public query func get_all_proposals() : async [(Int, Proposal)] {
        let ret : [(Int, Proposal)] = Iter.toArray<(Int, Proposal)>(store.entries());
        return ret
    };

    system func preupgrade() {
        stable_store := Iter.toArray(store.entries())
    };

    system func postupgrade() {
        stable_store := []
    };

    ///////////////////////////////////
    // lock neurons
    //////////////////////////////////

    // public shared ({ caller }) func lock_neuron(account : Int, delay : Int) : async Result.Result<Text, ()> {
    //     // assert not Principal.isAnonymous(caller);
    //     // assert account.Tokens > 1_000_000_000_000;

    //     let neuron = Neuron {
    //         id = caller;
    //         locked_tokens = Int;
    //         state = # locked;
    //         delay = Time.now() + delay
    //     };
    //     all_neurons.put(neuronId, neuron);
    //     #ok("Tokens locked in Neuron with id: " # Principal.toText(caller))
    // };

    // public query func get_all_neurons() : async [(Nat, Neuron)] {
    //     Iter.toArray(all_neurons);
    // };

    // public shared ({ caller }) func set_neuron_dissolving(account : Int, delay : Int) : async Result.Result<Text, ()> {
    //     // assert not Principal.isAnonymous(caller);

    //     all_neurons.put(neuronId, neuron);
    //     #ok("Tokens locked in Neuron with id: " # Principal.toText(caller))
    // };

}
