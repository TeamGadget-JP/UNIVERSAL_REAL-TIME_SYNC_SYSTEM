# URSS G-HUB v1.1.0 — Protocol Quick Reference

## Network

```text
Control TCP : 127.0.0.1:8000
Protocol    : 1
Encoding    : UTF-8
Framing     : one JSON object per line (\n)
UDP Base    : 8020 default
Body        : 8021-8025
Facial      : 8041-8045
Generic     : 8060
```

Endpoint MUST obey `PORT_ASSIGN` / `ROUTE`. Do not use UDP port as Slot/Object identity.

## Community HELLO

```json
{"type":"HELLO","protocol_version":1,"endpoint_type":"external","capabilities":["generic_data_send"]}
```

Response:

```json
{"type":"ASSIGN","endpoint_id":1,"session_id":123456789}
```

Possible HELLO `REJECT.reason`:

```text
invalid_json
hello_required
unsupported_protocol_version
unsupported_endpoint_type
```

## Capabilities

```text
character_transform_send
character_transform_receive
shape_key_send
shape_key_receive
generic_data_send
generic_data_receive
timeline_send
timeline_receive
```

## Channel flow

Sender:

```text
CHANNEL_ADD
CHANNEL_REGISTERED
READY(channel_id)
ROUTE
UDP -> route host:port
```

Receiver:

```text
CHANNEL_ADD
CHANNEL_REGISTERED
PORT_ASSIGN
bind UDP
READY(channel_id, port)
ROUTE
receive UDP
```

`CHANNEL_ADD`:

```json
{"type":"CHANNEL_ADD","channel_type":"generic_data_send","local_id":1,"match_id":"generic_main"}
```

`CHANNEL_REGISTERED`:

```json
{"type":"CHANNEL_REGISTERED","channel_id":10,"local_id":1}
```

Sender `READY`:

```json
{"type":"READY","channel_id":10}
```

Receiver `READY`:

```json
{"type":"READY","channel_id":11,"port":8060}
```

Bind failure:

```json
{"type":"PORT_FAIL","channel_id":11,"port":8060,"reason":"bind failed"}
```

## Routing

Known pairs:

```text
character_transform_send <-> character_transform_receive
shape_key_send           <-> shape_key_receive
generic_data_send        <-> generic_data_receive
```

Per profile + `match_id`, route requires exactly one sender and one receiver.

`match_id` comparison is case-insensitive.

## Ownership

```text
Body Source Owner : character_transform_send only
Shape Sender      : independent
Generic Sender    : independent
Destination Owner : common to all receiver profiles
```

One active Destination Endpoint session at a time.

## RELAY

Bidirectional opaque JSON over an established route:

```json
{"type":"RELAY","route_id":4,"payload":{"command":"EXAMPLE"}}
```

G-HUB does not interpret payload semantics.

## Timeline

Publish / claim:

```json
{"type":"TIMELINE_PUBLISH","time_seconds":1.25,"is_playing":true,"claim_owner":true}
```

Owner tick:

```json
{"type":"TIMELINE_PUBLISH","time_seconds":1.30,"is_playing":true,"claim_owner":false}
```

Request state:

```json
{"type":"TIMELINE_SYNC_REQUEST"}
```

Release:

```json
{"type":"TIMELINE_RELEASE"}
```

Canonical state:

```json
{"type":"TIMELINE_STATE","time_seconds":1.3,"is_playing":true,"owner_endpoint_id":1,"owner_session_id":123456789,"revision":42}
```

## Disconnect

There is no public `DISCONNECT` message in v1.1.0.

Close TCP. G-HUB performs route/channel/port/ownership/timeline cleanup and reevaluates waiting candidates.

## Do not depend on

```text
private G-HUB classes
IL layout
internal fields
endpoint_id persistence
fixed UDP-to-slot mapping
CHANNEL_REMOVE (not public v1.1.0 flow)
```
