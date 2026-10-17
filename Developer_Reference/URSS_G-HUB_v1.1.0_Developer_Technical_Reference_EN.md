# URSS G-HUB v1.1.0 Developer Technical Reference
## Protocol / Routing / Endpoint Integration / Platform Contract

**Target:** G-HUB v1.1.0 Vanilla  
**Protocol Version:** 1  
**Published by:** TeamGadget / URSS  
**Document Revision:** 1.0 / 2026-10-17

---

## 0. Purpose and Scope of This Document

This document is the developer technical reference for G-HUB v1.1.0. Its purpose is to enable the URSS Community to **implement custom Endpoints and Extensions without analyzing G-HUB's internal implementation**.

G-HUB's internal source code, private APIs, binary layout, and internal class structure are not compatibility contracts. Community Endpoints should depend only on the **external Control Protocol / Capability / Channel / Route / Timeline / Generic Transport Contracts** defined in this document.

This document uses the following RFC-style requirement terms:

- **MUST**: Required for correct interoperability
- **MUST NOT**: Prohibited for a conforming implementation
- **SHOULD**: Recommended unless there is a specific reason not to
- **MAY**: Optional

### 0.1 Role of G-HUB

G-HUB is not a server that interprets application-specific semantics.

G-HUB is responsible for:

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

Endpoints are responsible for:

```text
Application Semantics
Object / Rig / Camera / Prop Binding
Coordinate Conversion
Payload Encoding / Decoding
Animation Evaluation
Schema Interpretation
Host Application API Integration
```

This responsibility boundary is one of the most important principles of the URSS Platform.

> The platform is designed so that adding a new Prop / Camera / Light / Constraint / Custom Data schema should not, in principle, require changes to G-HUB itself.

---

# 1. Overall Architecture

URSS v1.1.0 separates the **Control Plane** from the **Data Plane**.

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

G-HUB does not proxy normal high-frequency Data Plane UDP payloads.

G-HUB tells the Endpoint the destination `host` and `port`; Data Plane traffic then flows directly between Endpoints.

### 1.1 Current Connection Model

The Vanilla policy in G-HUB v1.1.0 is:

- Body Source: 1 Endpoint
- Destination: 1 Endpoint
- Shape Key Source: independent from the Body Source
- Generic Sender: independent from the Body Source
- Canonical Timeline: capability-based
- Character Slots: C1-C5 in Vanilla
- G-HUB accepts `endpoint_type=external`

A Facial Source such as SE / ShapeMixer may coexist with a Body Source.

A Generic Sender may also coexist with a Body Source.

However, **Destination Ownership is shared across all receiver profiles**. When Body / Facial / Generic are used together, their receiver channels should normally belong to the same Destination Endpoint session.

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

The G-HUB v1.1.0 Control Server binds to loopback (`127.0.0.1`).

Therefore, the Vanilla v1.1.0 Control Plane assumes **Endpoints running on the same machine**.

### 2.2 JSON framing

Each Control Message MUST be sent as **one JSON object per line**.

```json
{"type":"HELLO","protocol_version":1,"endpoint_type":"external","capabilities":["generic_data_send"]}
```

Pretty-printed multi-line JSON MUST NOT be used.

### 2.3 G-HUB Protocol Version vs. Application Version

The Control Protocol version used by G-HUB v1.1.0 is:

```text
1
```


`G-HUB v1.1.0` and `protocol_version: 1` are separate concepts.

Endpoints MUST send `protocol_version: 1` in HELLO.

---

# 3. Port Authority

G-HUB is the sole authority for Data Plane port assignment.

Endpoints MUST NOT treat fixed UDP ports as part of the Endpoint contract.

Endpoints MUST follow G-HUB's `PORT_ASSIGN` / `ROUTE` messages.

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

### 3.2 Important: Port and Slot Are Not the Same Thing

Do not hard-code assumptions such as `8021 = C1`.

Within the Body range, free ports are assigned dynamically to receiver channels from the lowest available number. With normal C1-C5 registration order this may appear to line up with slots, but that is not part of the Endpoint Contract.

**Use `local_id`, `match_id`, and Route metadata for Slot / Object identity. Do not use the UDP port as identity.**

### 3.3 Saved Settings

G-HUB does not automatically overwrite an existing UDP Base in `settings.json` with 8020.

Community Endpoints must therefore never assume the default ports and should always treat Control Plane assignment as authoritative.

---

# 4. Endpoint Type

Accepted `endpoint_type` values in G-HUB v1.1.0:

```text
cascadeur
shapemixer
unity
blender
godot
external
```

Community / custom Endpoints should normally use:

```text
external
```


Endpoint type matching is case-insensitive and is normalized to lowercase inside G-HUB.

### 4.1 External Endpoint

`external` is the official Platform entry point for URSS Community Endpoints.

It allows an Endpoint to participate in the existing routing core through documented capabilities without requiring a G-HUB rebuild or a new endpoint type.

---

# 5. Capability Contract

Primary capabilities defined in v1.1.0:

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

Capability strings are declared during HELLO.

G-HUB trims capability strings, normalizes them to lowercase, and removes duplicates.

### 5.1 Capabilities Cannot Be Added After HELLO

An Endpoint cannot later create a channel through `CHANNEL_ADD` for a capability it did not declare in HELLO.

For example:

```json
{
  "type": "HELLO",
  "protocol_version": 1,
  "endpoint_type": "external",
  "capabilities": ["generic_data_send"]
}
```

If an Endpoint connects with the HELLO above and later sends:

```json
{
  "type": "CHANNEL_ADD",
  "channel_type": "character_transform_send",
  "local_id": 1,
  "match_id": "char_01"
}
```

the channel registration is rejected.

### 5.2 Undefined Capabilities

HELLO can carry arbitrary capability strings, but G-HUB v1.1.0 defines routing / timeline behavior only for the capabilities documented here.

Declaring an unknown capability does not automatically create a new route profile.

---

# 6. Endpoint Lifecycle

Basic lifecycle:

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

G-HUB v1.1.0 does not define a `DISCONNECT` message.

**Closing the TCP session is the authoritative disconnect signal.**

Endpoints should close the TCP connection when shutting down.

---

# 7. Identity Model

G-HUB uses several kinds of IDs.

| ID | Assigned by | Lifetime | Meaning |
|---|---|---|---|
| `endpoint_id` | G-HUB | current G-HUB process/session | connected endpoint instance |
| `session_id` | G-HUB | one TCP endpoint session | reconnect protection / session identity |
| `channel_id` | G-HUB | registered channel lifetime | G-HUB channel identity |
| `route_id` | G-HUB | route lifetime | established route identity |
| `local_id` | Endpoint | endpoint-defined | local channel/object/slot mapping |
| `match_id` | Endpoint | channel lifetime | sender/receiver pairing key |

## 7.1 endpoint_id / session_id Are Not Persistent IDs

A reconnect receives a new `endpoint_id` and `session_id`.

Do not store these values as persistent identity in project assets.

### 7.2 session_id

`session_id` is generated as a non-zero value within the positive range of a signed 64-bit integer.

It is a session identity used to prevent stale-session cleanup errors; it is not an authentication credential.

### 7.3 local_id

`local_id` is a positive integer chosen by the Endpoint.

Within one Endpoint session, the same `channel_type + local_id` combination cannot be registered twice.

Examples from the official Vanilla convention:

```text
Body:   1..5
Face:   1001..1005
```

G-HUB itself does not assign application-specific meaning to these numeric values.

### 7.4 match_id

`match_id` is the logical key that pairs a sender with a receiver.

Routing comparison is case-insensitive.

Official convention:

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

Recommended initial Generic convention:

```text
generic_main
```

G-HUB does not interpret the semantic meaning of the `match_id` string.

---

# 8. Control Message Reference

## 8.1 HELLO

**Direction:** Endpoint -> G-HUB  
**MUST be:** the first message on the TCP connection

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
| `protocol_version` | int | `1` in v1.1.0 |
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

> Could a future Endpoint X that TeamGadget does not even know exists join G-HUB by reading only this document?

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
