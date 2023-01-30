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
import T "types";
import Prim "mo:⛔";

import I "icmancan";

shared (init_msg) actor class Dao() = this {

    ////////////////////////////////////////
    // section -> types, variables, memory
    //////////////////////////////////

    stable var transfer_fee : Nat = 10_000_000;
    stable var next_proposal_id : Nat = 0;
    stable var neuronId : Int = 0;
    stable var stable_store : [(Int, T.Proposal)] = [];
    stable var stable_neurons : [(Int, T.Neuron)] = [];
    stable var stable_accounts : [(Principal, Account)] = [];

    func intHash(n : Int) : Hash.Hash {
        Text.hash(Int.toText(n))
    };

    let all_neurons = HashMap.fromIter<Int, T.Neuron>(stable_neurons.vals(), Iter.size(stable_store.vals()), Int.equal, intHash);
    let store = HashMap.fromIter<Int, T.Proposal>(stable_store.vals(), Iter.size(stable_neurons.vals()), Int.equal, intHash);
    let all_accounts = HashMap.fromIter<Principal, Account>(stable_accounts.vals(), Iter.size(stable_accounts.vals()), Principal.equal, Principal.hash);

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

    public shared ({ caller }) func submit_proposal(payload : T.ProposalPayload) : async {
        #Ok : T.Proposal;
        #Err : Text
    } {
        assert not Principal.isAnonymous(caller);
        var voting_power = await bootcampCan.icrc1_balance_of({
            owner = caller;
            subaccount = null
        });
        if (voting_power < 10_000_000_000) {
            return #Err("You must hold at least 1 MB token to create a proposal.")
        };
        let proposal_id = next_proposal_id;
        next_proposal_id += 1;

        var prop : T.Proposal = {
            id = proposal_id;
            timestamp = Time.now();
            proposer = caller;
            payload;
            state = #open;
            votes_yes = 0;
            votes_no = 0;
            voters = List.nil()
        };

        store.put(proposal_id, prop);
        return #Ok(prop)
    };

    public shared ({ caller }) func vote(proposal_id : Int, yes_or_no : Bool) : async T.Result<(Nat, Nat), Text> {
        assert not Principal.isAnonymous(caller);

        switch (store.get(proposal_id)) {
            case (null) {
                return #err("No proposal with id " # Int.toText(proposal_id) # " exists")
            };
            case (?some) {
                var state = some.state;
                if (state != #open) {
                    return #err("Proposal " # Int.toText(proposal_id) # " is not open for voting")
                };

                if (List.some(some.voters, func(e : Principal) : Bool = e == caller)) {
                    return #err("Already voted")
                };
                let account : Account = { owner = caller; subaccount = null };
                var voting_power = await bootcampCan.icrc1_balance_of(account);
                var votes_yes : Nat = some.votes_yes;
                var votes_no : Nat = some.votes_no;

                if (yes_or_no) {
                    votes_yes := 1000
                } else {
                    votes_no := 1000
                };

                let voters = List.push(caller, some.voters);
                if (votes_yes >= T.one_hundred_tokens) {
                    state := #accepted
                };
                if (votes_no >= T.one_hundred_tokens) {
                    state := #rejected
                };

                let updated_proposal = {
                    id = some.id;
                    votes_yes;
                    votes_no;
                    voters;
                    state;
                    timestamp = some.timestamp;
                    proposer = some.proposer;
                    payload = some.payload
                };
                store.put(some.id, updated_proposal);

                return #ok(updated_proposal.votes_yes, updated_proposal.votes_no)
            }
        }
    };

    public query func get_proposal(id : Int) : async ?T.Proposal {
        store.get(id)
    };

    public query func get_all_proposals() : async [(Int, T.Proposal)] {
        let ret : [(Int, T.Proposal)] = Iter.toArray<(Int, T.Proposal)>(store.entries());
        return ret
    };

    public func execute_accepted_proposals() : async () {
        let ret : [(Int, T.Proposal)] = Iter.toArray<(Int, T.Proposal)>(store.entries());
        for ((item, proposal) in ret.vals()) {
            if (proposal.votes_yes >= 10_000_000_000) {
                ignore update_proposal_status(proposal, #succeeded)
            }
        }
    };

    let webpageCan : actor {
        notify_approved_proposals : (T.Proposal) -> async ()
    } = actor ("2f3dc-hiaaa-aaaaj-aifdq-cai");

    private func update_proposal_status(proposal : T.Proposal, state : T.ProposalState) : async () {
        let updated = {
            state;
            id = proposal.id;
            votes_yes = proposal.votes_yes;
            votes_no = proposal.votes_no;
            voters = proposal.voters;
            timestamp = proposal.timestamp;
            proposer = proposal.proposer;
            payload = proposal.payload
        };
        store.put(proposal.id, updated);
        ignore webpageCan.notify_approved_proposals(proposal)
    };

    ///////////////////////////////////////
    // section -> register user with account
    //////////////////////////////////

    public shared ({ caller }) func register_user(principal : Principal, account : Account) : async Result.Result<Text, Text> {
        assert not Principal.isAnonymous(caller);

        switch (all_accounts.get(principal)) {
            case (?some) { #err("user already exists" )};
            case (null) {
                all_accounts.put(principal, account);
                #ok("user with account has been registered");
            }
        };

    };

    ////////////////////////////////////////
    // section -> system calls
    //////////////////////////////////

    system func preupgrade() {
        stable_store := Iter.toArray(store.entries());
        stable_neurons := Iter.toArray(all_neurons.entries());
        stable_accounts := Iter.toArray(all_accounts.entries());
    };

    system func postupgrade() {
        stable_store := [];
        stable_neurons := [];
        stable_accounts := [];
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
        if (tokens <= 100_000_000) {
            return #err("Your balance of MB tokens is too low for staking in neurons.")
        };
        if (amount <= 100_000_000) {
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

        let neuron : T.Neuron = {
            id = caller;
            account;
            locked_tokens = amount;
            state = # locked;
            delay = Time.now() + delay
        };
        all_neurons.put(neuronId, neuron);
        #ok("Tokens locked in Neuron with id: " # Principal.toText(caller))
    };

    public query func get_neuron(id : Int) : async ?T.Neuron {
        all_neurons.get(id)
    };

    public query func get_all_neurons() : async [(Int, T.Neuron)] {
        let ret : [(Int, T.Neuron)] = Iter.toArray<(Int, T.Neuron)>(all_neurons.entries());
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

    public shared ({ caller }) func set_neuron_dissolving(id : Int) : async () {
        assert not Principal.isAnonymous(caller);

        let ret : [(Int, T.Neuron)] = Iter.toArray<(Int, T.Neuron)>(all_neurons.entries());
        for ((item, neuron) in ret.vals()) {
            if (neuron.id == caller) {

                if (neuron.state == #dissolved) {
                    ignore transfer_to_user_account(neuron)
                } else {
                    let updated_neuron : T.Neuron = {
                        id = caller;
                        account = neuron.account;
                        locked_tokens = neuron.locked_tokens;
                        state = # dissolving;
                        delay = 0
                    };
                    all_neurons.put(id, updated_neuron)
                }

            } else {}
        }
    };

    public func transfer_to_user_account(n : T.Neuron) : async T.Result<Text, Text> {
        let user_id = n.id;
        let account : Account = { owner = user_id; subaccount = null };
        let args : TransferArgs = {
            from_subaccount = null;
            to = account;
            amount = n.locked_tokens;
            fee = null;
            memo = Text.encodeUtf8("neuron dissolved for ");
            created_at_time = Nat64.fromIntWrap(Time.now())
        };

        switch (do_transfer(args)) {
            case (Ok) {
                #ok("The payment to the user succeeded")
            };
            case (Err) {
                #err("The payment of tokens to the wallet of user failed")
            }
        }
    };

    ///////////////////////////////////
    // section -> internet identity
    ///////////////////////////////

    public type Purpose = { #authentication; #recovery };
    public type KeyType = { #platform; #seed_phrase; #cross_platform; #unknown };
    public type PublicKey = [Nat8];
    public type CredentialId = [Nat8];
    public type DeviceKey = PublicKey;
    public type DeviceData = {
        alias : Text;
        pubkey : DeviceKey;
        key_type : KeyType;
        purpose : Purpose;
        credential_id : ?CredentialId
    };
    public type FrontendHostname = Text;
    public type UserNumber = Nat64;
    public type ChallengeKey = Text;
    public type ChallengeResult = { key : ChallengeKey; chars : Text };
    public type RegisterResponse = {
        #bad_challenge;
        #canister_full;
        #registered : { user_number : UserNumber }
    };

    let identityCan : actor {
        get_principal : shared query (
            UserNumber,
            FrontendHostname,
        ) -> async Principal;
        register : shared (DeviceData, ChallengeResult) -> async RegisterResponse
    } = actor ("rdmx6-jaaaa-aaaaa-aaadq-cai");

    public func get_principal_from_II(user_number : UserNumber, frontendname : FrontendHostname) : async Principal {
        let p : Principal = await identityCan.get_principal(user_number, frontendname);
        return p
    };

    ///////////////////////////////////
    // section -> ic-management canister
    ///////////////////////////////

    let ic : I.IC = actor ("aaaaa-aa");
    public func get_canister_status(id : I.canister_id) : async {
        cycles : Nat;
        idle_cycles_burned_per_day : Nat;
        memory_size : Nat
    } {

        let x = await ic.canister_status({ canister_id = id });
        return {
            cycles = x.cycles;
            idle_cycles_burned_per_day = x.idle_cycles_burned_per_day;
            memory_size = x.memory_size
        }
    };

}
