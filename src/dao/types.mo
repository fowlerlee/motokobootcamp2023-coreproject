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

    public type VotingError = {
        #notOpen;
        #alreadyVoted;
        #notEnoughVotingPower;
        #doesNotExist
    };

    public type Proposal = {
        id : Nat;
        var voters : List.List<Principal>;
        var state : ProposalState;
        timestamp : Int;
        proposer : Principal;
        var votes_yes : Tokens;
        var votes_no : Tokens;
        content : Text;
        title : Text
    };

    public type ProposalState = {
        #failed : Text;
        #open;
        #rejected;
        #accepted
    };

}
