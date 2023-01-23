import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import List "mo:base/List";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Time "mo:base/Time";
import Error "mo:base/Error";
import Option "mo:base/Option";
import Trie "mo:base/Trie";
import Nat64 "mo:base/Nat64";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";

shared (init_msg) actor class Dao() = this {

    ////////////////////////////////////////
    // section -> types, variables, memory
    //////////////////////////////////

    type Proposal = {
        id : Int;
        text : Text;
        principal : Principal;
        vote_yes : Nat;
        vote_no : Nat
    };

    type Neuron = {
        id : Principal;
        account : Account;
        locked_tokens : Int;
        state : { #locked; #dissolved; #dissolving };
        delay : Int
    };

    stable var transfer_fee : Nat = 10000000;
    stable var proposalId : Int = 0;
    stable var neuronId : Int = 0;
    stable var stable_store : [(Int, Proposal)] = [];
    stable var stable_neurons : [(Int, Neuron)] = [];

    func intHash(n : Int) : Hash.Hash {
        Text.hash(Int.toText(n))
    };

    let all_neurons = HashMap.fromIter<Int, Neuron>(stable_neurons.vals(), Iter.size(stable_store.vals()), Int.equal, intHash);
    let store = HashMap.fromIter<Int, Proposal>(stable_store.vals(), Iter.size(stable_neurons.vals()), Int.equal, intHash);

    public func get_principal() : async Principal {
        return Principal.fromActor(this)
    };

    let bootcampCan : actor {
        icrc1_balance_of : (Account) -> async (Nat);
        icrc1_transfer : (TransferArgs) -> async ({
            Ok : Nat;
            Err : TransferError
        })
    } = actor ("db3eq-6iaaa-aaaah-abz6a-cai");

    public shared ({ caller }) func submit_proposal(this_payload : Text) : async {
        #Ok : Proposal;
        #Err : Text
    } {
        assert not Principal.isAnonymous(caller);
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
        assert not Principal.isAnonymous(caller);
        switch (store.get(proposal_id)) {
            case (null) {
                return #Err("No proposal with id " # Int.toText(proposal_id) # " exists")
            };
            case (?some) {
                let account : Account = { owner = caller; subaccount = null };
                var voting_power = await bootcampCan.icrc1_balance_of(account);
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

    public func execute_accepted_proposals() : async () {
        let ret : [(Int, Proposal)] = Iter.toArray<(Int, Proposal)>(store.entries());
        for (item in ret.vals()) {
            let id = item.1.text;
            let prop = item.1;
            if (prop.vote_yes >= 10000000000) {
                ignore update_proposal_status(prop)
            }
        }
    };

    let webpageCan : actor {
        notify_approved_proposals : (Proposal) -> async ()
    } = actor ("2f3dc-hiaaa-aaaaj-aifdq-cai");

    private func update_proposal_status(p : Proposal) : async () {
        await webpageCan.notify_approved_proposals(p)
    };

    ////////////////////////////////////////
    // section -> system calls
    //////////////////////////////////

    system func preupgrade() {
        stable_store := Iter.toArray(store.entries());
        stable_neurons := Iter.toArray(all_neurons.entries())
    };

    system func postupgrade() {
        stable_store := [];
        stable_neurons := []
    };

    ///////////////////////////////////
    // section -> neurons
    ///////////////////////////////

    type TokenResult = { Ok : Nat; Err : TransferError };
    type Subaccount = Blob;
    type Account = { owner : Principal; subaccount : ?Subaccount };
    type TransferError = {
        BadFee : { expected_fee : Nat };
        BadBurn : { min_burn_amount : Nat };
        InsufficientFunds : { balance : Nat };
        TooOld : {};
        CreatedInFuture : { ledger_time : Nat64 };
        Duplicate : { duplicate_of : Nat };
        TemporarilyUnavailable : {};
        GenericError : { error_code : Nat; message : Text }
    };
    type TransferArgs = {
        from_subaccount : ?Subaccount;
        to : Account;
        amount : Nat;
        fee : ?Nat;
        memo : Blob;
        created_at_time : Nat64
    };

    private func get_balance(acc : Account) : async Nat {
        return await bootcampCan.icrc1_balance_of(acc)
    };

    private func do_transfer(args : TransferArgs) : async TokenResult {
        return await bootcampCan.icrc1_transfer(args)
    };

    public shared ({ caller }) func lock_neuron(amount : Nat, delay : Int) : async Result.Result<Text, Text> {
        assert not Principal.isAnonymous(caller);

        let account : Account = { owner = caller; subaccount = null };
        let tokens : Nat = await get_balance(account);
        if (tokens <= 100000000) {
            return #err("Your balance of MB tokens is too low for staking in neurons.")
        };
        if (amount <= 100000000) {
            return #err("The minimum tokens for creatnig neurons is 100000000. Consider locking more tokens in neurons.")
        };

        let trans_args : TransferArgs = {
            from_subaccount = null;
            to = account;
            amount;
            fee = ?transfer_fee;
            memo = Text.encodeUtf8("neuron created");
            created_at_time = Nat64.fromIntWrap(Time.now())
        };

        ignore do_transfer(trans_args);

        let neuron : Neuron = {
            id = caller;
            account;
            locked_tokens = amount;
            state = # locked;
            delay = Time.now() + delay
        };
        all_neurons.put(neuronId, neuron);
        #ok("Tokens locked in Neuron with id: " # Principal.toText(caller))
    };

    public query func get_neuron(id : Int) : async ?Neuron {
        all_neurons.get(id)
    };

    public query func get_all_neurons() : async [(Int, Neuron)] {
        let ret : [(Int, Neuron)] = Iter.toArray<(Int, Neuron)>(all_neurons.entries());
        return ret
    };

    // Utility function that helps writing assertion-driven code more concisely.
    private func expect<T>(opt : ?T, violation_msg : Text) : T {
        switch (opt) {
            case (null) {
                Debug.trap(violation_msg)
            };
            case (?x) {
                x
            }
        }
    };

    public shared ({ caller }) func set_neuron_dissolving(id : Int) : async Result.Result<Text, Text> {
        assert not Principal.isAnonymous(caller);

        #ok("Tokens dissolving in Neuron with id: " # Principal.toText(caller))
    }

    // BELOW IS UNDER CONSTRUCTION - please ignore - will move to a branch and continue there

    // public query func get_neuron_from_principal_if_exists(caller : Principal) : async ?Neuron {
    //     let ret : [(Int, Neuron)] = Iter.toArray<(Int, Neuron)>(all_neurons.entries());
    //     for (item in ret.vals()) {
    //         if(item.1.id == caller){
    //             return item.1;
    //         } else {
    //             return null;
    //         }
    //     }
    //     return;
    // };

    // public query func get_neuron_from_principal_if_exists(caller : Principal) : async [Neuron] {

    //     // could probably allocate more but this is minimum
    //     let buff : Buffer.Buffer<Neuron> = Buffer.Buffer(all_neurons.size());
    //     for ((id, neuronz) in all_neurons.entries()) {
    //         let b : Buffer.Buffer<Neuron> = Buffer.Buffer(all_neurons.size());
    //         for (item in neuronz.vals()) {

    //         };
    //         buff.append(b)
    //     };
    //     Buffer.toArray(buff)
    // };

}
