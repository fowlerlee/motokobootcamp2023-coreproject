import Http = "http";
import Text = "mo:base/Text";
import CD "mo:base/CertifiedData";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import List "mo:base/List";

actor {
  var txt : Text = "";
  var pr : Text = "";

  public shared ({ caller }) func hello(text : Text) : async Text {
    // assert not Principal.isAnonymous(caller);
    CD.set(((Text.encodeUtf8(text))));
    txt := "Hello, your text is " # text # ". Did you know the latest approved proposal is: " # pr;
    return txt
  };

  public query ({ caller }) func certificate() : async ?Blob {
    // assert not Principal.isAnonymous(caller);
    return CD.getCertificate()
  };

  type Proposal = {
    id : Int;
    text : Text;
    principal : Principal;
    vote_yes : Nat;
    vote_no : Nat
  };

  public shared func notify_approved_proposals(prop : Proposal) : async () {
    pr := prop.text
  };

  public type HttpRequest = Http.HttpRequest;
  public type HttpResponse = Http.HttpResponse;

  public query func http_request(req : HttpRequest) : async HttpResponse {
    return ({
      body = Text.encodeUtf8(txt);
      status_code = 200;
      headers = [];
      streaming_strategy = null
    })
  }
}
