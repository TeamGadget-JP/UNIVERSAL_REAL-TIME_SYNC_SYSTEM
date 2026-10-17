# URSS G-HUB v1.1.0 — 프로토콜 Quick Reference

## 네트워크

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

Endpoint는 반드시 `PORT_ASSIGN` / `ROUTE`를 따라야 합니다. UDP port를 Slot/Object identity로 사용하지 마십시오.

## Community HELLO

```json
{"type":"HELLO","protocol_version":1,"endpoint_type":"external","capabilities":["generic_data_send"]}
```

응답:

```json
{"type":"ASSIGN","endpoint_id":1,"session_id":123456789}
```

가능한 HELLO `REJECT.reason`:

```text
invalid_json
hello_required
unsupported_protocol_version
unsupported_endpoint_type
```

## Capability

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

## Channel 흐름

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

Bind 실패:

```json
{"type":"PORT_FAIL","channel_id":11,"port":8060,"reason":"bind failed"}
```

## Routing

정의된 pair:

```text
character_transform_send <-> character_transform_receive
shape_key_send           <-> shape_key_receive
generic_data_send        <-> generic_data_receive
```

profile + `match_id`별로 route에는 정확히 하나의 sender와 하나의 receiver가 필요합니다.

`match_id` 비교는 대소문자를 구분하지 않습니다.

## Ownership

```text
Body Source Owner : character_transform_send only
Shape Sender      : independent
Generic Sender    : independent
Destination Owner : common to all receiver profiles
```

동시에 활성화되는 Destination Endpoint session은 하나입니다.

## RELAY

성립된 route에서 사용하는 양방향 opaque JSON:

```json
{"type":"RELAY","route_id":4,"payload":{"command":"EXAMPLE"}}
```

G-HUB는 payload semantics를 해석하지 않습니다.

## Timeline

Publish / claim:

```json
{"type":"TIMELINE_PUBLISH","time_seconds":1.25,"is_playing":true,"claim_owner":true}
```

Owner tick:

```json
{"type":"TIMELINE_PUBLISH","time_seconds":1.30,"is_playing":true,"claim_owner":false}
```

State 요청:

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

v1.1.0에는 public `DISCONNECT` 메시지가 없습니다.

TCP를 닫으십시오. G-HUB가 route/channel/port/ownership/timeline cleanup을 수행하고 대기 중인 후보를 다시 평가합니다.

## 의존하지 말아야 할 것

```text
private G-HUB classes
IL layout
internal fields
endpoint_id persistence
fixed UDP-to-slot mapping
CHANNEL_REMOVE (not public v1.1.0 flow)
```
