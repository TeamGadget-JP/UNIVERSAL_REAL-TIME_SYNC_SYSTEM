# URSS G-HUB v1.1.0 Developer Technical Reference
## Protocol / Routing / Endpoint Integration / Platform Contract

**対象:** G-HUB v1.1.0 Vanilla  
**Protocol Version:** 1  
**発行:** TeamGadget / URSS  
**文書版:** 1.0 / 2026-10-17

---

## 0. この資料の位置づけ

この資料は、URSS Community が **G-HUB の内部実装を解析しなくても、独自 Endpoint / Extension を実装できる**ことを目的とした G-HUB v1.1.0 の開発者向け技術リファレンスです。

G-HUB の内部ソースコード、private API、binary layout、内部 class 構成は互換性契約ではありません。Community Endpoint が依存すべきなのは、本資料で定義する **外部 Control Protocol / Capability / Channel / Route / Timeline / Generic Transport Contract** です。

本資料では RFC 風に次の用語を使います。

- **MUST**: 正常な相互運用のため必須
- **MUST NOT**: 実装してはいけない
- **SHOULD**: 原則として従うことを推奨
- **MAY**: 任意

### 0.1 G-HUB の役割

G-HUB はアプリケーション固有の意味を処理するサーバーではありません。

G-HUB が担当するもの:

```text
Endpoint Registration
Capability Declaration
Channel Registration
Match / Routing
UDP Port Assignment
Route-scoped Control Relay
Body Source Ownership
Single Destination Ownership
Canonical Timeline
Lifecycle / Cleanup
Diagnostics
```

Endpoint が担当するもの:

```text
Application Semantics
Object / Rig / Camera / Prop Binding
Coordinate Conversion
Payload Encoding / Decoding
Animation Evaluation
Schema Interpretation
Host Application API Integration
```

この責務境界は URSS Platform の最重要原則です。

> 新しい Prop / Camera / Light / Constraint / Custom Data Schema を追加するだけなら、原則として G-HUB 本体変更を必要としない構造を目標とします。

---

# 1. 全体アーキテクチャ

URSS v1.1.0 は **Control Plane** と **Data Plane** を分離しています。

```text
                    Control Plane
             TCP 127.0.0.1 : 8000

       +------------- G-HUB -------------+
       | Registration / Route / Timeline |
       +----------------------------------+
          ^                         ^
          | JSON Lines              | JSON Lines
          |                         |
     Source Endpoint           Destination Endpoint
          |                         ^
          |                         |
          +------ UDP Data ---------+
                 direct path
```

G-HUB は通常の高頻度 Data Plane UDP payload を proxy しません。

G-HUB は Endpoint に送信先の `host` と `port` を通知し、Data Plane は Endpoint 間で直接通信します。

### 1.1 現行の接続モデル

G-HUB v1.1.0 の Vanilla policy は次の通りです。

- Body Source: 1 Endpoint
- Destination: 1 Endpoint
- Shape Key Source: Body Source と独立
- Generic Sender: Body Source と独立
- Canonical Timeline: Capability ベース
- Character Slot: Vanilla では C1-C5
- G-HUB は `endpoint_type=external` を受理

SE / ShapeMixer のような Facial Source は Body Source と同時に存在できます。

Generic Sender も Body Source と同時に存在できます。

ただし **Destination Ownership は receiver profile 全体で共通**です。Body / Facial / Generic を同時利用する場合、それらの receiver channel は同じ Destination Endpoint session に所属する構成が基本です。

---

# 2. Network Contract

## 2.1 Control Plane

Default:

```text
Protocol : TCP
Host     : 127.0.0.1
Port     : 8000
Encoding : UTF-8 (no BOM)
Framing  : one JSON object per line
Newline  : \n
```

G-HUB v1.1.0 の Control Server は loopback (`127.0.0.1`) に bind します。

したがって Vanilla v1.1.0 の Control Plane は **同一マシン上の Endpoint を前提**とします。

### 2.2 JSON framing

各 Control Message は **1 行の JSON object** として送信します。

```json
{"type":"HELLO","protocol_version":1,"endpoint_type":"external","capabilities":["generic_data_send"]}
```

Pretty Print された複数行 JSON は MUST NOT です。

### 2.3 G-HUB Protocol Version と Application Version

G-HUB v1.1.0 の Control Protocol version は:

```text
1
```

です。

`G-HUB v1.1.0` と `protocol_version: 1` は別の概念です。

Endpoint は HELLO で必ず `protocol_version: 1` を送信します。

---

# 3. Port Authority

G-HUB は Data Plane Port の唯一の authority です。

Endpoint は固定 UDP port を Endpoint 契約として保持してはいけません。

Endpoint は G-HUB の `PORT_ASSIGN` / `ROUTE` に従います。

## 3.1 v1.1.0 Default Layout

Default UDP Base:

```text
8020
```

Default layout:

```text
Control TCP      8000
Body C1-C5       8021-8025
Facial C1-C5     8041-8045
Generic          8060
```

Formula:

```text
Body    = UDP Base + 1 .. +5
Facial  = UDP Base + 21 .. +25
Generic = UDP Base + 40
```

### 3.2 重要: Port と Slot は同一ではない

`8021 = C1` のように hard-code してはいけません。

Body range は receiver channel に対して空いている port を低い番号から動的に割り当てます。通常の C1-C5 登録順では結果として一致して見えることがありますが、これは Endpoint Contract ではありません。

**Slot / Object identity は `local_id` / `match_id` / Route metadata で扱い、UDP port を identity に使わないでください。**

### 3.3 Saved Settings

G-HUB は既存 `settings.json` の UDP Base を自動的に 8020 へ上書きしません。

したがって Community Endpoint は default port を想定せず、常に Control Plane の assignment を authority としてください。

---

# 4. Endpoint Type

G-HUB v1.1.0 が受理する `endpoint_type`:

```text
cascadeur
shapemixer
unity
blender
godot
external
```

Community / custom Endpoint は原則として:

```text
external
```

を使用することを推奨します。

Endpoint type は大文字小文字を区別せず、G-HUB 内で lowercase に正規化されます。

### 4.1 External Endpoint

`external` は URSS Community のための正式な Platform entry point です。

G-HUB の再ビルドや endpoint type 追加を要求せず、documented capability の範囲で既存 routing core に参加できます。

---

# 5. Capability Contract

v1.1.0 で定義された主要 capability:

| Capability | Direction | Purpose |
|---|---|---|
| `character_transform_send` | Source | Body transform sender |
| `character_transform_receive` | Destination | Body transform receiver |
| `shape_key_send` | Source | Facial / Shape Key sender |
| `shape_key_receive` | Destination | Facial / Shape Key receiver |
| `generic_data_send` | Source | Generic extensible data sender |
| `generic_data_receive` | Destination | Generic extensible data receiver |
| `timeline_send` | Control | Publish / own Canonical Timeline |
| `timeline_receive` | Control | Receive Canonical Timeline |

Capability strings は HELLO 時に宣言します。

G-HUB は capability string を trim + lowercase 化し、重複を除去します。

### 5.1 Capability は後付けできない

Endpoint が HELLO で宣言しなかった capability を、後から `CHANNEL_ADD` で作ることはできません。

例えば:

```json
{
  "type": "HELLO",
  "protocol_version": 1,
  "endpoint_type": "external",
  "capabilities": ["generic_data_send"]
}
```

と接続した Endpoint が、後から:

```json
{
  "type": "CHANNEL_ADD",
  "channel_type": "character_transform_send",
  "local_id": 1,
  "match_id": "char_01"
}
```

を送っても reject されます。

### 5.2 未定義 capability

HELLO 自体は任意の文字列 capability を保持できますが、G-HUB v1.1.0 が routing / timeline behavior を定義しているのは本資料に記載された capability です。

未知 capability を宣言しただけで新しい route profile が自動生成されるわけではありません。

---

# 6. Endpoint Lifecycle

基本 lifecycle:

```text
TCP CONNECT
    |
    v
HELLO
    |
    +---- REJECT -> connection ends
    |
    v
ASSIGN
    |
    v
CHANNEL_ADD (0..N)
    |
    v
CHANNEL_REGISTERED
    |
    v
PORT_ASSIGN (receiver only)
    |
    v
READY
    |
    v
ROUTE
    |
    v
ACTIVE DATA / RELAY / TIMELINE
    |
    v
TCP CLOSE
    |
    v
G-HUB cleanup / ROUTE_REMOVE / ownership release
```

### 6.1 Disconnect

G-HUB v1.1.0 に `DISCONNECT` message はありません。

**TCP session の close が authoritative disconnect signal** です。

Endpoint は終了時に TCP connection を閉じてください。

---

# 7. Identity Model

G-HUB には複数種類の ID があります。

| ID | Assigned by | Lifetime | Meaning |
|---|---|---|---|
| `endpoint_id` | G-HUB | current G-HUB process/session | connected endpoint instance |
| `session_id` | G-HUB | one TCP endpoint session | reconnect protection / session identity |
| `channel_id` | G-HUB | registered channel lifetime | G-HUB channel identity |
| `route_id` | G-HUB | route lifetime | established route identity |
| `local_id` | Endpoint | endpoint-defined | local channel/object/slot mapping |
| `match_id` | Endpoint | channel lifetime | sender/receiver pairing key |

## 7.1 endpoint_id / session_id は永続 ID ではない

Reconnect では新しい `endpoint_id` と `session_id` が発行されます。

これらを project asset の永続 identity として保存してはいけません。

### 7.2 session_id

`session_id` は 0 ではない signed 64-bit positive range に収まる値として生成されます。

これは stale session cleanup を防ぐための session identity であり、authentication credential ではありません。

### 7.3 local_id

`local_id` は Endpoint が決める正の整数です。

同一 Endpoint session 内では、同じ `channel_type + local_id` の二重登録はできません。

公式 Vanilla convention の例:

```text
Body:   1..5
Face:   1001..1005
```

ただし G-HUB 自体はこれらの数値にアプリケーション固有意味を持ちません。

### 7.4 match_id

`match_id` は sender と receiver を結ぶ logical key です。

Routing comparison は case-insensitive です。

公式 convention:

```text
char_01
char_02
char_03
char_04
char_05

face_01
face_02
face_03
face_04
face_05
```

Generic の推奨 initial convention:

```text
generic_main
```

G-HUB は `match_id` の文字列意味を解釈しません。

---

# 8. Control Message Reference

## 8.1 HELLO

**Direction:** Endpoint -> G-HUB  
**MUST be:** TCP connection の最初の message

```json
{
  "type": "HELLO",
  "protocol_version": 1,
  "endpoint_type": "external",
  "capabilities": [
    "generic_data_send",
    "timeline_send",
    "timeline_receive"
  ]
}
```

Required fields:

| Field | Type | Notes |
|---|---|---|
| `type` | string | exact `HELLO` |
| `protocol_version` | int | v1.1.0では `1` |
| `endpoint_type` | string | allowed endpoint type |
| `capabilities` | string[] | may be empty |

HELLO rejection reason:

```text
invalid_json
hello_required
unsupported_protocol_version
unsupported_endpoint_type
```

G-HUB returns:

```json
{
  "type": "REJECT",
  "reason": "unsupported_protocol_version"
}
```

and closes the connection.

---

## 8.2 ASSIGN

**Direction:** G-HUB -> Endpoint

```json
{
  "type": "ASSIGN",
  "endpoint_id": 1,
  "session_id": 98314714981496425
}
```

After `ASSIGN`, Endpoint MAY register channels and use declared timeline capabilities.

---

## 8.3 CHANNEL_ADD

**Direction:** Endpoint -> G-HUB

```json
{
  "type": "CHANNEL_ADD",
  "channel_type": "generic_data_send",
  "local_id": 1,
  "match_id": "generic_main"
}
```

Rules:

- `local_id` MUST be > 0
- `channel_type` MUST have been declared in HELLO capabilities
- `match_id` SHOULD be non-empty for routable data channel
- same session + same channel type + same local ID cannot be registered twice

G-HUB normalizes `channel_type` to lowercase.

---

## 8.4 CHANNEL_REGISTERED

**Direction:** G-HUB -> Endpoint

```json
{
  "type": "CHANNEL_REGISTERED",
  "channel_id": 12,
  "local_id": 1
}
```

`local_id` is returned so the Endpoint can map the new G-HUB `channel_id` back to its local object/slot.

G-HUB sends `CHANNEL_REGISTERED` **before** subsequent routing actions such as `PORT_ASSIGN`.

---

## 8.5 PORT_ASSIGN

**Direction:** G-HUB -> Receiver Endpoint only

```json
{
  "type": "PORT_ASSIGN",
  "channel_id": 12,
  "port": 8060
}
```

Receiver MUST:

1. bind the assigned UDP port
2. if successful, send `READY` including the same port
3. if bind fails, send `PORT_FAIL`

Sender channels do not receive `PORT_ASSIGN`.

---

## 8.6 READY

### Sender READY

**Direction:** Sender Endpoint -> G-HUB

```json
{
  "type": "READY",
  "channel_id": 7
}
```

### Receiver READY

**Direction:** Receiver Endpoint -> G-HUB

```json
{
  "type": "READY",
  "channel_id": 12,
  "port": 8060
}
```

Receiver MUST return the exact port assigned by G-HUB.

Route is created only after both sender and receiver channels are READY.

---

## 8.7 PORT_FAIL

**Direction:** Receiver Endpoint -> G-HUB

```json
{
  "type": "PORT_FAIL",
  "channel_id": 12,
  "port": 8060,
  "reason": "bind failed"
}
```

G-HUB validates that:

- channel belongs to this Endpoint session
- channel is a receiver channel
- `port` equals its currently assigned port

For Body / Facial ranges G-HUB may assign another free port.

Generic v1.1.0 has only one Generic port. Therefore a failure of that port has no alternate Generic port in the same channel lifetime. Endpoint reconnect / channel lifecycle reset can release failure state and allow normal reuse once the OS port becomes available.

---

## 8.8 ROUTE

**Direction:** G-HUB -> both Sender and Receiver

```json
{
  "type": "ROUTE",
  "route_id": 4,
  "source_endpoint_id": 1,
  "source_session_id": 111111,
  "source_channel_id": 7,
  "target_endpoint_id": 2,
  "target_session_id": 222222,
  "target_channel_id": 12,
  "host": "127.0.0.1",
  "port": 8060
}
```

Sender uses:

```text
host + port
```

as the Data Plane destination.

Both Endpoint sides SHOULD verify the route metadata belongs to their current session/channel before accepting it.

`route_id` is also used by route-scoped `RELAY` and may be included in Endpoint-level UDP envelopes.

---

## 8.9 ROUTE_REMOVE

**Direction:** G-HUB -> surviving Endpoint / rollback target

```json
{
  "type": "ROUTE_REMOVE",
  "route_id": 4
}
```

On receipt, Endpoint MUST stop using that route and discard route-local cached state.

A future route may receive a new `route_id`, port, peer, or session identity.

---

## 8.10 RELAY

**Direction:** Endpoint -> G-HUB -> opposite side of an established route

```json
{
  "type": "RELAY",
  "route_id": 4,
  "payload": {
    "command": "EXAMPLE_COMMAND",
    "value": 123
  }
}
```

G-HUB forwards:

```json
{
  "type": "RELAY",
  "route_id": 4,
  "payload": {
    "command": "EXAMPLE_COMMAND",
    "value": 123
  }
}
```

Properties:

- bidirectional within the established route
- only an Endpoint that belongs to the route may use it
- G-HUB does not inspect application semantics
- payload is opaque JSON from G-HUB perspective

Typical uses in existing URSS workflows include route-specific control transactions such as START / Smart Swizzle / Bake / Bridge-related coordination.

Community developers MAY define their own RELAY payload contract between compatible Endpoint implementations.

Do not require G-HUB to understand those commands.

---

# 9. Routing Contract

G-HUB v1.1.0 knows three route profiles:

```text
character_transform_send  <-> character_transform_receive
shape_key_send            <-> shape_key_receive
generic_data_send         <-> generic_data_receive
```

## 9.1 Pairing rule

A route profile is evaluated per `match_id`.

Route creation requires:

```text
exactly 1 sender
exactly 1 receiver
same match_id (case-insensitive)
ownership allowed
receiver port assigned
sender READY
receiver READY
```

### 9.2 Smart silence / match conflict

If a given profile + match ID has:

```text
0 sender
0 receiver
multiple senders
multiple receivers
```

G-HUB does not guess.

Multiple candidates generate a `Match conflict` diagnostic and no route is established.

Community Endpoint MUST use unambiguous match IDs.

---

# 10. Ownership Contract

Ownership is session-based, not application-name-based.

## 10.1 Body Source Ownership

Only `character_transform_send` participates in Primary Body Source ownership.

The first Body Source Endpoint session that successfully establishes a Body route becomes owner.

While it remains connected, Body channels from another Endpoint session remain registered but unrouted.

When the owner disconnects, ownership is released and waiting candidates are reevaluated automatically.

```text
Body Source A -> active owner
Body Source B -> waiting

A disconnects
    |
    v
B may automatically route
```

## 10.2 Shape Key Sender

`shape_key_send` does not consume Body Source ownership.

This preserves the standard:

```text
GHEC Body + SE Facial -> one Destination
```

workflow.

## 10.3 Generic Sender

`generic_data_send` is also independent from Body Source ownership.

For example, platform design permits conceptually:

```text
GHEC     -> Body
SE       -> Facial
Tool X   -> Generic Camera / Custom Data
```

as separate source Endpoint sessions.

## 10.4 Destination Ownership

Destination ownership is shared across receiver profiles.

The first Endpoint session that successfully establishes a receiver route becomes current Destination Owner.

A receiver channel belonging to a different Endpoint session is blocked until the owner disconnects.

This enforces the Vanilla policy:

```text
one active destination application at a time
```

Therefore Body + Facial + Generic should normally be received by channels registered under the **same Destination Endpoint session** when they need to coexist.

---

# 11. Data Plane

## 11.1 Direct Endpoint-to-Endpoint UDP

After ROUTE:

```text
Sender -> UDP -> Receiver
```

G-HUB is not in the high-frequency packet path.

Benefits:

- G-HUB remains application-agnostic
- high-frequency payload does not burden Control Plane
- schemas can evolve at Endpoint level

## 11.2 What G-HUB does not define

G-HUB does not parse or reinterpret:

- bone transform packet layout
- Shape Key packet layout
- Generic schema payload
- coordinate systems
- Quaternion/Euler convention
- host object names
- rig semantics
- camera semantics
- prop semantics

These belong to Endpoint / schema contracts.

### 11.3 Existing Body / Facial compatibility

To implement a new Endpoint that interoperates with official Body or Facial senders, the Endpoint must implement the corresponding URSS Data Plane packet contract used by the official Endpoint line.

That packet-level specification is separate from this G-HUB Control Protocol document.

---

# 12. Generic Data Channel

Generic Data is **not Prop-specific**.

Its purpose is to provide one extensible route for application-defined data such as:

```text
Prop
Camera
Light
Constraint-related data
Custom metadata
Unknown future schemas
```

Capabilities:

```text
generic_data_send
generic_data_receive
```

Default Generic UDP port under UDP Base 8020:

```text
8060
```

Generic does not consume Character Slots.

One Generic route is intended to multiplex multiple logical objects and schema types.

## 12.1 Recommended match ID

```text
generic_main
```

This is a convention, not G-HUB semantics.

## 12.2 Generic Reference Envelope v1

The following envelope was designed during G-HUB v1.1.0 Platform Foundation as the recommended Generic transport format.

**Important:** G-HUB itself does not parse or enforce this envelope. It is an Endpoint-level companion contract and can evolve independently if compatible Endpoint implementations agree.

All integers and floating-point values are little-endian.

Fixed header size: 32 bytes.

| Field | Type | Size | Meaning |
|---|---|---:|---|
| Magic | ASCII | 4 | `URGD` |
| Version | uint8 | 1 | envelope version, currently `1` |
| Flags | uint8 | 1 | reserved, currently `0` |
| Header Size | uint16 | 2 | currently `32` |
| Route ID | uint32 | 4 | route ID from `ROUTE` |
| Sequence | uint32 | 4 | sender-local sequence |
| Timestamp Seconds | float64 | 8 | sample time |
| Object ID Length | uint16 | 2 | UTF-8 byte length |
| Schema ID Length | uint16 | 2 | UTF-8 byte length |
| Payload Length | uint32 | 4 | payload bytes |
| Object ID | UTF-8 | variable | logical transport identity |
| Schema ID | UTF-8 | variable | schema identity |
| Payload | bytes | variable | schema-defined content |

Equivalent Python `struct` header format:

```python
<4sBBHIIdHHI
```

Example schema IDs:

```text
urss.transform.v1
urss.camera.v1
vendor.example.custom.v1
```

### 12.3 Object ID

Object ID is a transport identity.

It MUST NOT be assumed to be identical to a Blender Object name, Unity GameObject name, Godot Node name, Cascadeur object name, etc.

Each Endpoint may bind Object ID to its host application however it chooses.

### 12.4 Datagram size

Recommended initial target:

```text
<= 1200 bytes per Generic UDP datagram where practical
```

Fragmentation/reassembly is not part of the v1 reference envelope.

Large assets SHOULD use a separate file/bridge workflow, with RELAY used only for route-scoped orchestration where appropriate.

---

# 13. Canonical Timeline

Timeline is a Control Plane feature and does not require a data channel.

Capabilities:

```text
timeline_send
timeline_receive
```

G-HUB maintains one Canonical Timeline State:

```text
time_seconds
is_playing
owner_endpoint_id
owner_session_id
revision
```

Initial state:

```text
time_seconds = 0.0
is_playing = false
owner = none
revision = 0
```

## 13.1 TIMELINE_PUBLISH

**Direction:** Endpoint -> G-HUB

```json
{
  "type": "TIMELINE_PUBLISH",
  "time_seconds": 1.25,
  "is_playing": true,
  "claim_owner": true
}
```

Requires:

```text
timeline_send
```

`time_seconds` MUST be finite.

### claim_owner = true

Represents an explicit local operation such as user scrub/play action.

The caller becomes timeline owner and the state is published.

### claim_owner = false

Represents a continuing playback tick.

Accepted only if the caller is already the current Timeline Owner.

Ticks from non-owner endpoints are silently ignored.

## 13.2 TIMELINE_STATE

**Direction:** G-HUB -> every connected `timeline_receive` Endpoint

```json
{
  "type": "TIMELINE_STATE",
  "time_seconds": 1.25,
  "is_playing": true,
  "owner_endpoint_id": 1,
  "owner_session_id": 98314714981496425,
  "revision": 42
}
```

The publishing Endpoint also receives this message if it owns `timeline_receive`.

This can be treated as the authoritative canonical state / ACK-equivalent.

Endpoint SHOULD use `revision` to reject stale locally queued updates where needed.

## 13.3 TIMELINE_SYNC_REQUEST

**Direction:** Endpoint -> G-HUB

```json
{
  "type": "TIMELINE_SYNC_REQUEST"
}
```

Requires:

```text
timeline_receive
```

G-HUB replies to that Endpoint with current `TIMELINE_STATE`.

Endpoint SHOULD request current state after ASSIGN when timeline synchronization is enabled, before allowing local polling to claim ownership.

## 13.4 TIMELINE_RELEASE

**Direction:** Endpoint -> G-HUB

```json
{
  "type": "TIMELINE_RELEASE"
}
```

Requires:

```text
timeline_send
```

If caller is owner:

- current timeline position is preserved
- playback becomes paused
- owner is cleared
- revision increments
- state is broadcast

If caller is not owner, release is a successful no-op.

## 13.5 Owner disconnect

If Timeline Owner disconnects, G-HUB:

1. preserves the last time position
2. sets `is_playing=false`
3. clears owner
4. increments revision
5. broadcasts the new state

---

# 14. Failure / Cleanup Semantics

Endpoint developers SHOULD treat disconnect and route replacement as normal lifecycle events, not exceptional states.

## 14.1 Endpoint disconnect cleanup

When an Endpoint TCP session disappears, G-HUB performs:

```text
1. invalidate endpoint session
2. remove control connection
3. cleanup timeline ownership
4. remove routes involving the endpoint
5. send ROUTE_REMOVE to surviving peers when possible
6. remove endpoint channels
7. release assigned UDP ports / failed-port state
8. release Body Source / Destination ownership if held
9. reevaluate waiting matches
```

### 14.2 Auto promotion

If an owner disconnects, waiting channels are reevaluated automatically.

Endpoint implementation SHOULD therefore remain connected and registered while waiting rather than repeatedly reconnecting in an attempt to steal ownership.

### 14.3 Route-local state

A new route MUST NOT inherit state from the previous route.

Clear as appropriate:

```text
peer identity
route_id
UDP target
START/STOP state
Smart Swizzle cache
Bake transaction state
object mapping caches tied to peer session
```

---

# 15. Message Handling Behavior

G-HUB returns explicit `REJECT` only during the initial HELLO handshake.

Many malformed or unauthorized post-handshake messages are ignored or only logged.

Endpoint MUST NOT assume every invalid message receives a NACK.

Correct implementations should validate locally and use G-HUB logs for diagnostics.

## 15.1 Case rules

Use exact documented message `type` strings:

```text
HELLO
CHANNEL_ADD
READY
PORT_FAIL
RELAY
TIMELINE_PUBLISH
TIMELINE_SYNC_REQUEST
TIMELINE_RELEASE
```

Message type dispatch is case-sensitive.

`endpoint_type`, HELLO capability strings, and `channel_type` are normalized to lowercase where documented.

`match_id` comparison is case-insensitive.

## 15.2 Reserved / non-public message definitions

G-HUB v1.1.0 contains message model names for `CHANNEL_REMOVE` / `CHANNEL_REMOVED`, but the v1.1.0 Control Server dispatcher does not expose them as a supported public lifecycle flow.

**Do not implement Endpoint logic that depends on CHANNEL_REMOVE in v1.1.0.**

Use TCP disconnect for endpoint-wide teardown, and `ROUTE_REMOVE` received from G-HUB for route teardown.

---

# 16. Minimal Generic Sender Sequence

A Community tool that sends Generic data can follow this sequence.

## Step 1: Connect

```text
TCP 127.0.0.1:8000
```

## Step 2: HELLO

```json
{"type":"HELLO","protocol_version":1,"endpoint_type":"external","capabilities":["generic_data_send"]}
```

## Step 3: Receive ASSIGN

```json
{"type":"ASSIGN","endpoint_id":4,"session_id":123456789}
```

## Step 4: Register sender channel

```json
{"type":"CHANNEL_ADD","channel_type":"generic_data_send","local_id":1,"match_id":"generic_main"}
```

## Step 5: Receive CHANNEL_REGISTERED

```json
{"type":"CHANNEL_REGISTERED","channel_id":21,"local_id":1}
```

## Step 6: READY

```json
{"type":"READY","channel_id":21}
```

## Step 7: Receive ROUTE

```json
{
  "type":"ROUTE",
  "route_id":11,
  "source_endpoint_id":4,
  "source_session_id":123456789,
  "source_channel_id":21,
  "target_endpoint_id":5,
  "target_session_id":987654321,
  "target_channel_id":22,
  "host":"127.0.0.1",
  "port":8060
}
```

## Step 8: Send UDP

Send Endpoint-defined Generic datagrams directly to:

```text
127.0.0.1:8060
```

until `ROUTE_REMOVE`, disconnect, or a replacement route invalidates that state.

---

# 17. Minimal Generic Receiver Sequence

## Step 1: HELLO

```json
{"type":"HELLO","protocol_version":1,"endpoint_type":"external","capabilities":["generic_data_receive"]}
```

## Step 2: ASSIGN

Receive Endpoint/session identity.

## Step 3: CHANNEL_ADD

```json
{"type":"CHANNEL_ADD","channel_type":"generic_data_receive","local_id":1,"match_id":"generic_main"}
```

## Step 4: CHANNEL_REGISTERED

Store `channel_id`.

## Step 5: PORT_ASSIGN

```json
{"type":"PORT_ASSIGN","channel_id":22,"port":8060}
```

Attempt UDP bind.

### Success

```json
{"type":"READY","channel_id":22,"port":8060}
```

### Failure

```json
{"type":"PORT_FAIL","channel_id":22,"port":8060,"reason":"bind failed"}
```

## Step 6: ROUTE

After both sides are READY, store route metadata and begin receiving UDP.

---

# 18. Minimal Python Control Client Skeleton

The following code shows the framing and handshake pattern only. It is intentionally not a complete production Endpoint SDK.

```python
import json
import socket

HOST = "127.0.0.1"
PORT = 8000


def send_line(file, obj):
    data = json.dumps(obj, separators=(",", ":"), ensure_ascii=False)
    file.write((data + "\n").encode("utf-8"))
    file.flush()


def recv_line(file):
    raw = file.readline()
    if not raw:
        raise ConnectionError("G-HUB control connection closed")
    return json.loads(raw.decode("utf-8"))


sock = socket.create_connection((HOST, PORT))
stream = sock.makefile("rwb")

send_line(stream, {
    "type": "HELLO",
    "protocol_version": 1,
    "endpoint_type": "external",
    "capabilities": ["generic_data_send"]
})

msg = recv_line(stream)
if msg.get("type") == "REJECT":
    raise RuntimeError(msg.get("reason"))
if msg.get("type") != "ASSIGN":
    raise RuntimeError(f"expected ASSIGN, got {msg}")

endpoint_id = int(msg["endpoint_id"])
session_id = int(msg["session_id"])

send_line(stream, {
    "type": "CHANNEL_ADD",
    "channel_type": "generic_data_send",
    "local_id": 1,
    "match_id": "generic_main"
})

while True:
    msg = recv_line(stream)
    t = msg.get("type")

    if t == "CHANNEL_REGISTERED":
        channel_id = int(msg["channel_id"])
        send_line(stream, {
            "type": "READY",
            "channel_id": channel_id
        })

    elif t == "ROUTE":
        route_id = int(msg["route_id"])
        host = msg["host"]
        udp_port = int(msg["port"])
        print("route ready", route_id, host, udp_port)

    elif t == "ROUTE_REMOVE":
        print("route removed", msg["route_id"])

    elif t == "TIMELINE_STATE":
        pass
```

Production Endpoint should additionally implement:

- reconnect strategy
- session state reset
- socket error handling
- asynchronous read/write
- route validation
- UDP bind/send lifecycle
- clean shutdown
- host application thread rules

---

# 19. Diagnostics

Useful G-HUB log patterns:

```text
HELLO accepted
HELLO rejected
Connected
ONLINE
Channel registered
PORT_ASSIGN
READY
SOURCE_OWNER
SOURCE_OWNER conflict
DESTINATION_OWNER
DESTINATION_OWNER conflict
ROUTE
RELAY
PORT_FAIL
Route removed
Channel removed
SOURCE_OWNER released
DESTINATION_OWNER released
Disconnected
OFFLINE
```

A healthy Body C1-C5 destination connection commonly shows:

```text
PORT_ASSIGN ... 8021
PORT_ASSIGN ... 8022
PORT_ASSIGN ... 8023
PORT_ASSIGN ... 8024
PORT_ASSIGN ... 8025
```

but Endpoint code MUST NOT depend on that ordering.

### 19.1 COPY LOG

G-HUB v1.1.0 includes `COPY LOG` for copying the currently displayed log to clipboard.

When requesting Community support, developers SHOULD include:

```text
G-HUB version
Endpoint version
HELLO capabilities
relevant CHANNEL_ADD / PORT_ASSIGN / READY / ROUTE lines
failure lines
reconnect result
```

---

# 20. Compatibility Rules for Community Endpoint Authors

## MUST

- send HELLO first
- use protocol version 1 for G-HUB v1.1.0
- use newline-delimited UTF-8 JSON
- declare capabilities before using them
- treat G-HUB as port authority
- use `match_id` for routing identity
- handle new endpoint/session/channel/route IDs after reconnect
- clear route-local state on ROUTE_REMOVE
- close TCP to disconnect
- keep application semantics out of assumptions about G-HUB

## MUST NOT

- hard-code Body/Facial/Generic destination port as identity
- assume `endpoint_id` survives reconnect/restart
- assume a specific official application must be the source
- send high-frequency Data Plane packets through RELAY
- depend on private G-HUB classes / field names / IL layout for normal Endpoint compatibility
- assume undocumented internal behavior will remain stable

## SHOULD

- use `endpoint_type=external` for Community Endpoint
- use stable descriptive `match_id` conventions
- validate route peer/session metadata
- tolerate destination/source owner waiting state
- implement reconnect without requiring G-HUB restart
- include protocol logs in bug reports
- keep Generic schemas versioned (`vendor.schema.v1` style)

---

# 21. Security / Trust Boundary

G-HUB v1.1.0 Control Server is local-loopback software.

The protocol does not provide:

```text
TLS
remote authentication
endpoint certificates
per-message signatures
permission scopes
```

`session_id` is routing/lifecycle identity, not an authentication secret.

Community developers MUST NOT expose the Control Server to an untrusted network through forwarding/proxying and then assume the v1 protocol provides network security.

Remote/networked URSS transport would require a separate security design.

---

# 22. Known v1.1.0 Boundaries

The following are deliberate current boundaries, not bugs in the Endpoint Contract.

```text
Single active Body Source Endpoint
Single active Destination Endpoint
C1-C5 Vanilla Character Slot policy
One Generic UDP port
No G-HUB Generic payload interpretation
No Generic fragmentation/reassembly
No multi-destination broadcast
No public CHANNEL_REMOVE lifecycle flow
Control Plane bound to localhost
Protocol version = 1 only
```

Community forks may experiment beyond these boundaries, but such behavior is not automatically part of Vanilla compatibility.

---

# 23. Unknown Endpoint Test

When designing an extension, use this question:

> TeamGadget が存在すら知らない将来の Endpoint X が、この文書だけを読んで G-HUB に参加できるか？

If the answer requires:

```text
editing G-HUB
knowing a private class name
hard-coding an internal field
assuming Cascadeur/Unity/Blender/Godot by name
```

then the design is probably application-specific and belongs in the Endpoint rather than the Platform Contract.

---

# 24. Recommended External Endpoint Validation

Before declaring compatibility with G-HUB v1.1.0, test at least:

### Registration

- HELLO -> ASSIGN
- unsupported protocol rejection
- reconnect receives a new identity

### Channel

- CHANNEL_ADD -> CHANNEL_REGISTERED
- undeclared capability is rejected
- duplicate local channel registration is rejected/does not create duplicates

### Receiver

- PORT_ASSIGN
- bind -> READY
- PORT_FAIL path

### Routing

- exactly one sender + receiver routes
- same `match_id` required
- match conflict produces no route
- ROUTE_REMOVE clears local state

### Ownership

- Body Source contender waits
- owner disconnect promotes waiting source
- Destination contender waits
- owner disconnect promotes waiting destination

### Generic

- Generic can coexist with Body / Facial sources without taking Body Source ownership
- Generic receiver participates in the same Destination ownership model
- multiple objects/schemas can share one Generic route at Endpoint level

### Timeline

- sync request
- local owner claim
- owner ticks
- non-owner tick ignored
- release
- owner disconnect pauses at last position

### Cleanup

- no stale UDP bind
- no stale route
- reconnect succeeds without G-HUB restart

---

# 25. Public Contract vs Internal Implementation

Community compatibility should be based on:

```text
this documented Control Protocol
published Data Plane contracts
published Generic schema/envelope contracts
official Vanilla Endpoint behavior
```

and not on:

```text
private C# class names
reflection into private members
IL offsets
method count
binary patch points
undocumented internal state
```

Binary modification can be a useful Community experiment, but it is a different compatibility layer from normal URSS Endpoint development and is not required to participate through `external`.

---

# 26. Quick Reference

```text
G-HUB v1.1.0
Protocol Version : 1
Control           : TCP 127.0.0.1:8000
Framing           : UTF-8 JSON Lines

Default UDP Base : 8020
Body              : 8021-8025
Facial            : 8041-8045
Generic           : 8060

Community Type    : external

Body              : character_transform_send / receive
Facial            : shape_key_send / receive
Generic           : generic_data_send / receive
Timeline          : timeline_send / timeline_receive

Routing Key       : match_id (case-insensitive)
Port Authority    : G-HUB
Data Plane        : Endpoint -> Endpoint UDP
Control Relay     : route-scoped opaque JSON
Body Source       : single owner
Destination       : single owner
Generic Sender    : independent of Body Source owner
Shape Sender      : independent of Body Source owner
Disconnect        : close TCP
```

---

# 27. Final Principle

G-HUB v1.1.0 is intentionally small in semantic responsibility.

It should know **where data goes, who owns the route, and whether the lifecycle is valid**.

It should not need to know **what a sword, camera, humanoid, quadruped, light, constraint, Blender Object, Unity GameObject, Godot Node, or future application object means**.

That separation is what allows URSS to remain stable while Community Endpoint implementations evolve independently.

---

**End of URSS G-HUB v1.1.0 Developer Technical Reference**
