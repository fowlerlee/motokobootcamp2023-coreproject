// This is a generated Motoko binding.
// Please use `import service "ic:canister_id"` instead to call canisters on the IC if possible.

module {
  public type Challenge = { png_base64 : Text; challenge_key : ChallengeKey };
  public type ChallengeKey = Text;
  public type ChallengeResult = { key : ChallengeKey; chars : Text };
  public type CredentialId = [Nat8];
  public type Delegation = {
    pubkey : PublicKey;
    targets : ?[Principal];
    expiration : Timestamp;
  };
  public type DeviceData = {
    alias : Text;
    pubkey : DeviceKey;
    key_type : KeyType;
    purpose : Purpose;
    credential_id : ?CredentialId;
  };
  public type DeviceKey = PublicKey;
  public type FrontendHostname = Text;
  public type GetDelegationResponse = {
    #no_such_delegation;
    #signed_delegation : SignedDelegation;
  };
  public type HeaderField = (Text, Text);
  public type HttpRequest = {
    url : Text;
    method : Text;
    body : [Nat8];
    headers : [HeaderField];
  };
  public type HttpResponse = {
    body : [Nat8];
    headers : [HeaderField];
    streaming_strategy : ?StreamingStrategy;
    status_code : Nat16;
  };
  public type InternetIdentityInit = {
    assigned_user_number_range : (Nat64, Nat64);
  };
  public type InternetIdentityStats = {
    users_registered : Nat64;
    assigned_user_number_range : (Nat64, Nat64);
  };
  public type KeyType = { #platform; #seed_phrase; #cross_platform; #unknown };
  public type ProofOfWork = { nonce : Nat64; timestamp : Timestamp };
  public type PublicKey = [Nat8];
  public type Purpose = { #authentication; #recovery };
  public type RegisterResponse = {
    #bad_challenge;
    #canister_full;
    #registered : { user_number : UserNumber };
  };
  public type SessionKey = PublicKey;
  public type SignedDelegation = {
    signature : [Nat8];
    delegation : Delegation;
  };
  public type StreamingCallbackHttpResponse = { token : ?Token; body : [Nat8] };
  public type StreamingStrategy = {
    #Callback : {
      token : Token;
      callback : shared query Token -> async StreamingCallbackHttpResponse;
    };
  };
  public type Timestamp = Nat64;
  public type Token = {};
  public type UserKey = PublicKey;
  public type UserNumber = Nat64;
  public type Self = ?InternetIdentityInit -> async actor {
    add : shared (UserNumber, DeviceData) -> async ();
    create_challenge : shared ProofOfWork -> async Challenge;
    get_delegation : shared query (
        UserNumber,
        FrontendHostname,
        SessionKey,
        Timestamp,
      ) -> async GetDelegationResponse;
    get_principal : shared query (
        UserNumber,
        FrontendHostname,
      ) -> async Principal;
    http_request : shared query HttpRequest -> async HttpResponse;
    init_salt : shared () -> async ();
    lookup : shared query UserNumber -> async [DeviceData];
    prepare_delegation : shared (
        UserNumber,
        FrontendHostname,
        SessionKey,
        ?Nat64,
      ) -> async (UserKey, Timestamp);
    register : shared (DeviceData, ChallengeResult) -> async RegisterResponse;
    remove : shared (UserNumber, DeviceKey) -> async ();
    stats : shared query () -> async InternetIdentityStats;
  }
}