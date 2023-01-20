import Http = "http";
import Text = "mo:base/Text";
import CD "mo:base/CertifiedData";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";

actor {
  var txt : Text = "";

  public shared ({caller}) func hello(text : Text) : async Text {
    // assert not Principal.isAnonymous(caller);
    CD.set(((Text.encodeUtf8(text))));
    txt := "Hello, your text is " # text;
    return txt;
  };

  public query ({caller}) func certificate() : async ?Blob {
    // assert not Principal.isAnonymous(caller);
    return CD.getCertificate();
  };

  public type HttpRequest = Http.HttpRequest;
  public type HttpResponse = Http.HttpResponse;

  public query func http_request(req : HttpRequest) : async HttpResponse {
    return ({
      body = Text.encodeUtf8(txt);
      status_code = 200;
      headers = [];
      streaming_strategy = null;
    })
  };
};