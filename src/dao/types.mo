import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Time "mo:base/Time";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import HashMap "mo:base/HashMap";
import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Hash "mo:base/Hash";
import Text "mo:base/Text";

module {

    public type Tokens = Nat;
    public let one_token = 10_000_000;
    public let one_hundred_tokens = 10_000_000_000;
    public let zeroToken = 0;
    public type Result<T, E> = Result.Result<T, E>;
    public type VoteArgs = { vote : Vote; proposal_id : Nat };

    type Account = { owner : Principal; subaccount : ?Subaccount };
    type Subaccount = Blob;
    public type Neuron = {
        id : Principal;
        account : Account;
        locked_tokens : Nat;
        state : { #locked; #dissolved; #dissolving };
        delay : Int
    };

    public type VotingError = {
        #notOpen;
        #alreadyVoted;
        #notEnoughVotingPower;
        #doesNotExist
    };

    public type Proposal = {
        id : Nat;
        votes_no : Tokens;
        voters : List.List<Principal>;
        state : ProposalState;
        timestamp : Int;
        proposer : Principal;
        votes_yes : Tokens;
        payload : ProposalPayload
    };

    public type ProposalPayload = {
        method : Text;
        canister_id : Principal;
        message : Blob
    };

    public type ProposalState = {
        #failed : Text;
        #open;
        #rejected;
        #succeeded;
        #accepted
    };

    public type TransferArgs = { to : Principal; amount : Tokens };
    public type Vote = { #no; #yes }
}
