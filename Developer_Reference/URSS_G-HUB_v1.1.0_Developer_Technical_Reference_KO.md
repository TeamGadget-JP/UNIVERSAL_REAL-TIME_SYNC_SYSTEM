# URSS G-HUB v1.1.0 개발자 기술 레퍼런스
## 프로토콜 / 라우팅 / 엔드포인트 통합 / 플랫폼 계약

**대상:** G-HUB v1.1.0 Vanilla  
**프로토콜 버전:** 1  
**발행:** TeamGadget / URSS  
**문서 리비전:** 1.0 / 2026-10-17

---

## 0. 이 문서의 목적과 범위

이 문서는 G-HUB v1.1.0 개발자용 기술 레퍼런스입니다. 목적은 URSS 커뮤니티가 **G-HUB의 내부 구현을 분석하지 않고도 커스텀 Endpoint와 Extension을 구현할 수 있도록 하는 것**입니다.

G-HUB의 내부 소스 코드, private API, 바이너리 레이아웃, 내부 클래스 구조는 호환성 계약이 아닙니다. Community Endpoint는 이 문서에서 정의하는 **외부 Control Protocol / Capability / Channel / Route / Timeline / Generic Transport Contract**에만 의존해야 합니다.

이 문서에서는 다음과 같은 RFC 스타일 요구 수준 용어를 사용합니다.

- **MUST**: 올바른 상호운용성을 위해 반드시 필요
- **MUST NOT**: 호환 구현에서 금지
- **SHOULD**: 특별한 이유가 없는 한 따를 것을 권장
- **MAY**: 선택 사항

### 0.1 G-HUB의 역할

G-HUB는 애플리케이션 고유의 의미를 해석하는 서버가 아닙니다.

G-HUB가 담당하는 영역:

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

Endpoint가 담당하는 영역:

```text
Application Semantics
Object / Rig / Camera / Prop Binding
Coordinate Conversion
Payload Encoding / Decoding
Animation Evaluation
Schema Interpretation
Host Application API Integration
```

이 책임 경계는 URSS Platform의 가장 중요한 원칙 중 하나입니다.

> 플랫폼은 새로운 Prop / Camera / Light / Constraint / Custom Data 스키마를 추가하는 것만으로는 원칙적으로 G-HUB 본체를 변경할 필요가 없도록 설계합니다.

---

# 1. 전체 아키텍처

URSS v1.1.0은 **Control Plane**과 **Data Plane**을 분리합니다.

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

G-HUB는 일반적인 고주파 Data Plane UDP payload를 프록시하지 않습니다.

G-HUB는 Endpoint에 목적지 `host`와 `port`를 알려주며, 이후 Data Plane 트래픽은 Endpoint 간에 직접 흐릅니다.

### 1.1 현재 연결 모델

G-HUB v1.1.0 Vanilla 정책은 다음과 같습니다.

- Body Source: Endpoint 1개
- Destination: Endpoint 1개
- Shape Key Source: Body Source와 독립
- Generic Sender: Body Source와 독립
- Canonical Timeline: Capability 기반
- Character Slot: Vanilla에서는 C1-C5
- G-HUB는 `endpoint_type=external`을 허용

SE / ShapeMixer와 같은 Facial Source는 Body Source와 동시에 존재할 수 있습니다.

Generic Sender 역시 Body Source와 동시에 존재할 수 있습니다.

단, **Destination Ownership은 모든 receiver profile에서 공유**됩니다. Body / Facial / Generic을 함께 사용할 경우, 해당 receiver channel은 일반적으로 동일한 Destination Endpoint session에 속해야 합니다.

---

# 2. 네트워크 계약

## 2.1 Control Plane

기본값:

```text
Protocol : TCP
Host     : 127.0.0.1
Port     : 8000
Encoding : UTF-8 (no BOM)
Framing  : one JSON object per line
Newline  : \n
```

G-HUB v1.1.0 Control Server는 loopback(`127.0.0.1`)에 bind합니다.

따라서 Vanilla v1.1.0 Control Plane은 **동일한 머신에서 실행되는 Endpoint**를 전제로 합니다.

### 2.2 JSON framing

각 Control Message는 반드시 **한 줄에 하나의 JSON object**로 전송해야 합니다.

```json
{"type":"HELLO","protocol_version":1,"endpoint_type":"external","capabilities":["generic_data_send"]}
```

Pretty Print된 여러 줄 JSON은 사용해서는 안 됩니다.

### 2.3 G-HUB Protocol Version과 Application Version

G-HUB v1.1.0에서 사용하는 Control Protocol version은 다음과 같습니다.

```text
1
```


`G-HUB v1.1.0`과 `protocol_version: 1`은 서로 다른 개념입니다.

Endpoint는 HELLO에서 반드시 `protocol_version: 1`을 전송해야 합니다.

---

# 3. Port Authority(포트 할당 권한)

G-HUB는 Data Plane 포트 할당의 유일한 authority입니다.

Endpoint는 고정 UDP 포트를 Endpoint 계약의 일부로 취급해서는 안 됩니다.

Endpoint는 G-HUB의 `PORT_ASSIGN` / `ROUTE` 메시지를 따라야 합니다.

## 3.1 v1.1.0 기본 레이아웃

기본 UDP Base:

```text
8020
```

기본 레이아웃:

```text
Control TCP      8000
Body C1-C5       8021-8025
Facial C1-C5     8041-8045
Generic          8060
```

계산식:

```text
Body    = UDP Base + 1 .. +5
Facial  = UDP Base + 21 .. +25
Generic = UDP Base + 40
```

### 3.2 중요: Port와 Slot은 같은 것이 아닙니다

`8021 = C1`과 같은 가정을 하드코딩하지 마십시오.

Body 범위에서는 사용 가능한 포트를 낮은 번호부터 receiver channel에 동적으로 할당합니다. 일반적인 C1-C5 등록 순서에서는 Slot과 일치해 보일 수 있지만, 이는 Endpoint Contract의 일부가 아닙니다.

**Slot / Object identity에는 `local_id`, `match_id`, Route metadata를 사용하십시오. UDP 포트를 identity로 사용하지 마십시오.**

### 3.3 저장된 설정

G-HUB는 `settings.json`에 이미 저장된 UDP Base를 자동으로 8020으로 덮어쓰지 않습니다.

따라서 Community Endpoint는 기본 포트를 가정해서는 안 되며, 항상 Control Plane의 할당을 authority로 취급해야 합니다.

---

# 4. Endpoint Type

G-HUB v1.1.0에서 허용되는 `endpoint_type` 값:

```text
cascadeur
shapemixer
unity
blender
godot
external
```

Community / custom Endpoint는 원칙적으로 다음 값을 사용하십시오.

```text
external
```


Endpoint type 비교는 대소문자를 구분하지 않으며 G-HUB 내부에서 lowercase로 정규화됩니다.

### 4.1 External Endpoint

`external`은 URSS Community Endpoint를 위한 공식 Platform 진입점입니다.

이를 통해 G-HUB 재빌드나 새로운 endpoint type 추가 없이, 문서화된 capability만으로 기존 routing core에 참여할 수 있습니다.

---

# 5. Capability Contract

v1.1.0에서 정의된 주요 capability:

| Capability | 방향 | 목적 |
|---|---|---|
| `character_transform_send` | Source | Body transform 송신 |
| `character_transform_receive` | Destination | Body transform 수신 |
| `shape_key_send` | Source | Facial / Shape Key 송신 |
| `shape_key_receive` | Destination | Facial / Shape Key 수신 |
| `generic_data_send` | Source | 확장 가능한 Generic data 송신 |
| `generic_data_receive` | Destination | 확장 가능한 Generic data 수신 |
| `timeline_send` | Control | Canonical Timeline publish / ownership |
| `timeline_receive` | Control | Canonical Timeline 수신 |

Capability string은 HELLO에서 선언합니다.

G-HUB는 capability string을 trim하고 lowercase로 정규화한 뒤 중복을 제거합니다.

### 5.1 HELLO 이후 Capability를 추가할 수 없음

Endpoint는 HELLO에서 선언하지 않은 capability에 대해 나중에 `CHANNEL_ADD`로 channel을 생성할 수 없습니다.

예:

```json
{
  "type": "HELLO",
  "protocol_version": 1,
  "endpoint_type": "external",
  "capabilities": ["generic_data_send"]
}
```

Endpoint가 위 HELLO로 연결한 뒤 다음 메시지를 전송하면:

```json
{
  "type": "CHANNEL_ADD",
  "channel_type": "character_transform_send",
  "local_id": 1,
  "match_id": "char_01"
}
```

channel 등록은 거부됩니다.

### 5.2 정의되지 않은 Capability

HELLO에는 임의의 capability string을 포함할 수 있지만, G-HUB v1.1.0이 routing / timeline 동작을 정의하는 것은 이 문서에 기재된 capability뿐입니다.

알 수 없는 capability를 선언한다고 해서 새로운 route profile이 자동으로 생성되지는 않습니다.

---

# 6. Endpoint Lifecycle

기본 lifecycle:

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

G-HUB v1.1.0에는 `DISCONNECT` 메시지가 정의되어 있지 않습니다.

**TCP session을 닫는 것이 authoritative disconnect signal입니다.**

Endpoint는 종료 시 TCP connection을 닫아야 합니다.

---

# 7. Identity Model

G-HUB는 여러 종류의 ID를 사용합니다.

| ID | 할당 주체 | 수명 | 의미 |
|---|---|---|---|
| `endpoint_id` | G-HUB | 현재 G-HUB process/session | 연결된 endpoint instance |
| `session_id` | G-HUB | 하나의 TCP endpoint session | reconnect 보호 / session identity |
| `channel_id` | G-HUB | 등록된 channel의 수명 | G-HUB channel identity |
| `route_id` | G-HUB | route 수명 | 성립된 route identity |
| `local_id` | Endpoint | endpoint 정의 | 로컬 channel/object/slot mapping |
| `match_id` | Endpoint | channel 수명 | sender/receiver pairing key |

## 7.1 endpoint_id / session_id는 영속 ID가 아님

Reconnect 시 새로운 `endpoint_id`와 `session_id`가 발급됩니다.

이 값을 project asset의 영속 identity로 저장하지 마십시오.

### 7.2 session_id

`session_id`는 signed 64-bit integer의 양수 범위 내에서 0이 아닌 값으로 생성됩니다.

이는 stale-session cleanup 오류를 방지하기 위한 session identity이며 authentication credential이 아닙니다.

### 7.3 local_id

`local_id`는 Endpoint가 정하는 양의 정수입니다.

하나의 Endpoint session에서 동일한 `channel_type + local_id` 조합을 중복 등록할 수 없습니다.

공식 Vanilla convention의 예:

```text
Body:   1..5
Face:   1001..1005
```

G-HUB 자체는 이 숫자에 애플리케이션 고유의 의미를 부여하지 않습니다.

### 7.4 match_id

`match_id`는 sender와 receiver를 연결하는 logical key입니다.

Routing 비교는 대소문자를 구분하지 않습니다.

공식 convention:

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

권장 초기 Generic convention:

```text
generic_main
```

G-HUB는 `match_id` 문자열의 의미를 해석하지 않습니다.

---

# 8. Control Message 레퍼런스

## 8.1 HELLO

**방향:** Endpoint -> G-HUB  
**MUST:** TCP connection에서 첫 번째 메시지여야 함

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

필수 필드:

| 필드 | 타입 | 비고 |
|---|---|---|
| `type` | string | 정확히 `HELLO` |
| `protocol_version` | int | v1.1.0에서는 `1` |
| `endpoint_type` | string | 허용된 endpoint type |
| `capabilities` | string[] | 비어 있어도 됨 |

HELLO 거부 사유:

```text
invalid_json
hello_required
unsupported_protocol_version
unsupported_endpoint_type
```

G-HUB 응답:

```json
{
  "type": "REJECT",
  "reason": "unsupported_protocol_version"
}
```

그리고 connection을 닫습니다.

---

## 8.2 ASSIGN

**방향:** G-HUB -> Endpoint

```json
{
  "type": "ASSIGN",
  "endpoint_id": 1,
  "session_id": 98314714981496425
}
```

`ASSIGN` 이후 Endpoint는 channel을 등록하고 선언한 timeline capability를 사용할 수 있습니다.

---

## 8.3 CHANNEL_ADD

**방향:** Endpoint -> G-HUB

```json
{
  "type": "CHANNEL_ADD",
  "channel_type": "generic_data_send",
  "local_id": 1,
  "match_id": "generic_main"
}
```

규칙:

- `local_id`는 반드시 0보다 커야 함
- `channel_type`은 HELLO capabilities에서 선언되어 있어야 함
- routable data channel의 `match_id`는 비어 있지 않는 것을 권장
- 동일 session + 동일 channel type + 동일 local ID는 중복 등록할 수 없음

G-HUB는 `channel_type`을 lowercase로 정규화합니다.

---

## 8.4 CHANNEL_REGISTERED

**방향:** G-HUB -> Endpoint

```json
{
  "type": "CHANNEL_REGISTERED",
  "channel_id": 12,
  "local_id": 1
}
```

`local_id`가 함께 반환되므로 Endpoint는 새 G-HUB `channel_id`를 자신의 local object/slot에 다시 매핑할 수 있습니다.

G-HUB는 `PORT_ASSIGN`과 같은 후속 routing 동작 **이전에** `CHANNEL_REGISTERED`를 전송합니다.

---

## 8.5 PORT_ASSIGN

**방향:** G-HUB -> Receiver Endpoint only

```json
{
  "type": "PORT_ASSIGN",
  "channel_id": 12,
  "port": 8060
}
```

Receiver는 반드시:

1. 할당된 UDP port에 bind하고
2. 성공하면 동일 port를 포함한 `READY`를 전송하며
3. bind에 실패하면 `PORT_FAIL`을 전송해야 합니다.

Sender channel은 `PORT_ASSIGN`을 받지 않습니다.

---

## 8.6 READY

### Sender READY

**방향:** Sender Endpoint -> G-HUB

```json
{
  "type": "READY",
  "channel_id": 7
}
```

### Receiver READY

**방향:** Receiver Endpoint -> G-HUB

```json
{
  "type": "READY",
  "channel_id": 12,
  "port": 8060
}
```

Receiver는 G-HUB가 할당한 정확한 port를 반환해야 합니다.

sender와 receiver channel이 모두 READY가 된 뒤에만 Route가 생성됩니다.

---

## 8.7 PORT_FAIL

**방향:** Receiver Endpoint -> G-HUB

```json
{
  "type": "PORT_FAIL",
  "channel_id": 12,
  "port": 8060,
  "reason": "bind failed"
}
```

G-HUB는 다음을 검증합니다.

- channel이 해당 Endpoint session에 속하는지
- channel이 receiver channel인지
- `port`가 현재 할당된 port와 일치하는지

Body / Facial 범위에서는 G-HUB가 다른 빈 port를 다시 할당할 수 있습니다.

Generic v1.1.0에는 Generic port가 하나뿐입니다. 따라서 해당 port가 실패하면 같은 channel lifetime 안에서 대체 Generic port가 없습니다. Endpoint reconnect / channel lifecycle reset으로 실패 상태를 해제할 수 있으며, OS port가 다시 사용 가능해지면 정상적으로 재사용할 수 있습니다.

---

## 8.8 ROUTE

**방향:** G-HUB -> Sender와 Receiver 모두

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

Sender는 다음을

```text
host + port
```

Data Plane 목적지로 사용합니다.

양쪽 Endpoint는 route metadata가 자신의 현재 session/channel에 해당하는지 확인한 뒤 수락하는 것을 권장합니다.

`route_id`는 route-scoped `RELAY`에도 사용되며 Endpoint 레벨 UDP envelope에 포함될 수 있습니다.

---

## 8.9 ROUTE_REMOVE

**방향:** G-HUB -> surviving Endpoint / rollback target

```json
{
  "type": "ROUTE_REMOVE",
  "route_id": 4
}
```

수신 즉시 Endpoint는 해당 route 사용을 중단하고 route-local cached state를 폐기해야 합니다.

향후 새 route에는 새로운 `route_id`, port, peer 또는 session identity가 할당될 수 있습니다.

---

## 8.10 RELAY

**방향:** Endpoint -> G-HUB -> 성립된 route의 반대편

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

G-HUB는 다음 형태로 전달합니다.

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

특성:

- 성립된 route 내부에서 양방향
- 해당 route에 속한 Endpoint만 사용 가능
- G-HUB는 application semantics를 검사하지 않음
- G-HUB 관점에서 payload는 opaque JSON

기존 URSS workflow에서는 START / Smart Swizzle / Bake / Bridge 관련 coordination과 같은 route-specific control transaction에 주로 사용됩니다.

Community 개발자는 서로 호환되는 Endpoint 구현 사이에 자체 RELAY payload contract를 정의할 수 있습니다.

그 명령의 의미를 G-HUB가 이해하도록 요구하지 마십시오.

---

# 9. Routing Contract

G-HUB v1.1.0은 세 가지 route profile을 알고 있습니다.

```text
character_transform_send  <-> character_transform_receive
shape_key_send            <-> shape_key_receive
generic_data_send         <-> generic_data_receive
```

## 9.1 Pairing 규칙

route profile은 `match_id`별로 평가됩니다.

Route 생성 조건:

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

특정 profile + match ID에 다음 상태가 있으면:

```text
0 sender
0 receiver
multiple senders
multiple receivers
```

G-HUB는 임의로 추측하지 않습니다.

후보가 여러 개이면 `Match conflict` 진단이 발생하며 route는 성립되지 않습니다.

Community Endpoint는 모호하지 않은 match ID를 사용해야 합니다.

---

# 10. Ownership Contract

Ownership은 application name이 아니라 session을 기준으로 합니다.

## 10.1 Body Source Ownership

`character_transform_send`만 Primary Body Source ownership에 참여합니다.

Body route를 최초로 성공적으로 성립시킨 Body Source Endpoint session이 owner가 됩니다.

owner가 연결되어 있는 동안 다른 Endpoint session의 Body channel은 등록 상태를 유지하지만 route되지 않습니다.

owner가 disconnect되면 ownership이 해제되고 대기 중인 후보를 자동으로 다시 평가합니다.

```text
Body Source A -> active owner
Body Source B -> waiting

A disconnects
    |
    v
B may automatically route
```

## 10.2 Shape Key Sender

`shape_key_send`는 Body Source ownership을 소비하지 않습니다.

이를 통해 다음 표준 구성을 유지합니다.

```text
GHEC Body + SE Facial -> one Destination
```

workflow입니다.

## 10.3 Generic Sender

`generic_data_send` 역시 Body Source ownership과 독립적입니다.

예를 들어 플랫폼 설계상 개념적으로 다음 구성이 가능합니다.

```text
GHEC     -> Body
SE       -> Facial
Tool X   -> Generic Camera / Custom Data
```

각각 별도의 source Endpoint session으로 동작할 수 있습니다.

## 10.4 Destination Ownership

Destination ownership은 receiver profile 전체에서 공유됩니다.

receiver route를 최초로 성공적으로 성립시킨 Endpoint session이 현재 Destination Owner가 됩니다.

다른 Endpoint session에 속한 receiver channel은 owner가 disconnect될 때까지 차단됩니다.

이로써 다음 Vanilla policy가 적용됩니다.

```text
one active destination application at a time
```

따라서 Body + Facial + Generic을 동시에 사용해야 할 경우 일반적으로 **동일한 Destination Endpoint session**에 등록된 channel에서 수신해야 합니다.

---

# 11. Data Plane

## 11.1 Endpoint 간 직접 UDP

ROUTE 성립 후:

```text
Sender -> UDP -> Receiver
```

G-HUB는 고주파 packet 경로에 포함되지 않습니다.

장점:

- G-HUB가 application-agnostic 상태를 유지
- 고주파 payload가 Control Plane에 부하를 주지 않음
- schema를 Endpoint 레벨에서 발전시킬 수 있음

## 11.2 G-HUB가 정의하지 않는 것

G-HUB는 다음 항목을 parse하거나 재해석하지 않습니다.

- bone transform packet layout
- Shape Key packet layout
- Generic schema payload
- coordinate system
- Quaternion/Euler convention
- host object name
- rig semantics
- camera semantics
- prop semantics

이 항목들은 Endpoint / schema contract의 책임입니다.

### 11.3 기존 Body / Facial 호환성

공식 Body 또는 Facial sender와 상호운용되는 새 Endpoint를 구현하려면, 공식 Endpoint 계열이 사용하는 해당 URSS Data Plane packet contract를 구현해야 합니다.

해당 packet-level specification은 이 G-HUB Control Protocol 문서와 별도입니다.

---

# 12. Generic Data Channel

Generic Data는 **Prop 전용이 아닙니다**.

목적은 다음과 같은 application-defined data를 하나의 확장 가능한 route로 운반하는 것입니다.

```text
Prop
Camera
Light
Constraint-related data
Custom metadata
Unknown future schemas
```

Capability:

```text
generic_data_send
generic_data_receive
```

UDP Base 8020 기준 기본 Generic UDP port:

```text
8060
```

Generic은 Character Slot을 소비하지 않습니다.

하나의 Generic route에서 여러 logical object와 schema type을 multiplex하는 것을 의도합니다.

## 12.1 권장 match ID

```text
generic_main
```

이는 convention이며 G-HUB semantics가 아닙니다.

## 12.2 Generic Reference Envelope v1

다음 envelope는 G-HUB v1.1.0 Platform Foundation 단계에서 권장 Generic transport format으로 설계되었습니다.

**중요:** G-HUB 자체는 이 envelope를 parse하거나 강제하지 않습니다. 이는 Endpoint 레벨의 companion contract이며, 호환 Endpoint 구현 간 합의가 있다면 독립적으로 발전할 수 있습니다.

모든 integer와 floating-point 값은 little-endian입니다.

고정 header 크기: 32 bytes.

| 필드 | 타입 | 크기 | 의미 |
|---|---|---:|---|
| Magic | ASCII | 4 | `URGD` |
| Version | uint8 | 1 | envelope version, 현재 `1` |
| Flags | uint8 | 1 | reserved, 현재 `0` |
| Header Size | uint16 | 2 | 현재 `32` |
| Route ID | uint32 | 4 | `ROUTE`에서 받은 route ID |
| Sequence | uint32 | 4 | sender-local sequence |
| Timestamp Seconds | float64 | 8 | sample time |
| Object ID Length | uint16 | 2 | UTF-8 byte 길이 |
| Schema ID Length | uint16 | 2 | UTF-8 byte 길이 |
| Payload Length | uint32 | 4 | payload byte 수 |
| Object ID | UTF-8 | variable | logical transport identity |
| Schema ID | UTF-8 | variable | schema identity |
| Payload | bytes | variable | schema가 정의하는 content |

동등한 Python `struct` header format:

```python
<4sBBHIIdHHI
```

Schema ID 예시:

```text
urss.transform.v1
urss.camera.v1
vendor.example.custom.v1
```

### 12.3 Object ID

Object ID는 transport identity입니다.

Object ID가 Blender Object name, Unity GameObject name, Godot Node name, Cascadeur object name 등과 동일하다고 가정해서는 안 됩니다.

각 Endpoint는 원하는 방식으로 Object ID를 host application에 bind할 수 있습니다.

### 12.4 Datagram 크기

권장 초기 목표:

```text
<= 1200 bytes per Generic UDP datagram where practical
```

Fragmentation/reassembly는 v1 reference envelope에 포함되지 않습니다.

대용량 asset은 별도의 file/bridge workflow를 사용하는 것을 권장하며, RELAY는 필요한 경우 route-scoped orchestration에만 사용해야 합니다.

---

# 13. Canonical Timeline

Timeline은 Control Plane 기능이며 data channel을 필요로 하지 않습니다.

Capability:

```text
timeline_send
timeline_receive
```

G-HUB는 하나의 Canonical Timeline State를 유지합니다.

```text
time_seconds
is_playing
owner_endpoint_id
owner_session_id
revision
```

초기 상태:

```text
time_seconds = 0.0
is_playing = false
owner = none
revision = 0
```

## 13.1 TIMELINE_PUBLISH

**방향:** Endpoint -> G-HUB

```json
{
  "type": "TIMELINE_PUBLISH",
  "time_seconds": 1.25,
  "is_playing": true,
  "claim_owner": true
}
```

필요 capability:

```text
timeline_send
```

`time_seconds`는 반드시 finite 값이어야 합니다.

### claim_owner = true

사용자 scrub/play 조작과 같은 명시적인 local operation을 나타냅니다.

호출자가 timeline owner가 되고 state가 publish됩니다.

### claim_owner = false

연속 playback tick을 나타냅니다.

호출자가 이미 현재 Timeline Owner인 경우에만 수락됩니다.

non-owner Endpoint의 tick은 조용히 무시됩니다.

## 13.2 TIMELINE_STATE

**방향:** G-HUB -> 연결된 모든 `timeline_receive` Endpoint

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

publish한 Endpoint도 `timeline_receive`를 가지고 있다면 이 메시지를 수신합니다.

이를 authoritative canonical state / ACK-equivalent로 취급할 수 있습니다.

Endpoint는 필요한 경우 `revision`을 사용해 stale local queued update를 거부하는 것을 권장합니다.

## 13.3 TIMELINE_SYNC_REQUEST

**방향:** Endpoint -> G-HUB

```json
{
  "type": "TIMELINE_SYNC_REQUEST"
}
```

필요 capability:

```text
timeline_receive
```

G-HUB는 해당 Endpoint에 현재 `TIMELINE_STATE`로 응답합니다.

timeline synchronization이 활성화된 경우 Endpoint는 ASSIGN 이후, local polling이 ownership을 claim하도록 허용하기 전에 현재 state를 요청하는 것을 권장합니다.

## 13.4 TIMELINE_RELEASE

**방향:** Endpoint -> G-HUB

```json
{
  "type": "TIMELINE_RELEASE"
}
```

필요 capability:

```text
timeline_send
```

호출자가 owner라면:

- 현재 timeline position 유지
- playback을 pause 상태로 변경
- owner 해제
- revision 증가
- state broadcast(브로드캐스트)

호출자가 owner가 아니라면 release는 성공한 no-op으로 처리됩니다.

## 13.5 Owner disconnect

Timeline Owner가 disconnect되면 G-HUB는:

1. 마지막 time position을 유지하고
2. `is_playing=false`로 설정하며
3. owner를 해제하고
4. revision을 증가시키며
5. 새로운 state를 broadcast합니다.

---

# 14. Failure / Cleanup 동작

Endpoint 개발자는 disconnect와 route replacement를 예외 상태가 아니라 정상 lifecycle event로 취급하는 것을 권장합니다.

## 14.1 Endpoint disconnect cleanup

Endpoint TCP session이 사라지면 G-HUB는 다음을 수행합니다.

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

owner가 disconnect되면 대기 중인 channel을 자동으로 다시 평가합니다.

따라서 Endpoint 구현은 ownership을 빼앗기 위해 반복 reconnect하지 말고, 대기 중에도 연결 및 등록 상태를 유지하는 것을 권장합니다.

### 14.3 Route-local state

새 route는 이전 route의 state를 상속해서는 안 됩니다.

필요에 따라 다음 상태를 초기화하십시오.

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

# 15. Message 처리 동작

G-HUB는 최초 HELLO handshake에서만 명시적인 `REJECT`를 반환합니다.

handshake 이후의 잘못된 메시지나 권한 없는 메시지 상당수는 무시되거나 log에만 기록됩니다.

Endpoint는 모든 잘못된 메시지가 NACK을 받는다고 가정해서는 안 됩니다.

올바른 구현은 로컬에서 validation을 수행하고 진단에는 G-HUB log를 사용해야 합니다.

## 15.1 대소문자 규칙

문서에 정의된 정확한 message `type` 문자열을 사용하십시오.

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

Message type dispatch는 대소문자를 구분합니다.

`endpoint_type`, HELLO capability string, `channel_type`은 문서에 명시된 대로 lowercase로 정규화됩니다.

`match_id` 비교는 대소문자를 구분하지 않습니다.

## 15.2 Reserved / non-public message 정의

G-HUB v1.1.0에는 `CHANNEL_REMOVE` / `CHANNEL_REMOVED` message model 이름이 존재하지만, v1.1.0 Control Server dispatcher는 이를 지원되는 public lifecycle flow로 노출하지 않습니다.

**v1.1.0에서 CHANNEL_REMOVE에 의존하는 Endpoint logic을 구현하지 마십시오.**

Endpoint 전체 teardown에는 TCP disconnect를 사용하고, route teardown에는 G-HUB에서 수신한 `ROUTE_REMOVE`를 사용하십시오.

---

# 16. 최소 Generic Sender 시퀀스

Generic data를 보내는 Community tool은 다음 순서를 따를 수 있습니다.

## Step 1: 연결

```text
TCP 127.0.0.1:8000
```

## Step 2: HELLO

```json
{"type":"HELLO","protocol_version":1,"endpoint_type":"external","capabilities":["generic_data_send"]}
```

## Step 3: ASSIGN 수신

```json
{"type":"ASSIGN","endpoint_id":4,"session_id":123456789}
```

## Step 4: sender channel 등록

```json
{"type":"CHANNEL_ADD","channel_type":"generic_data_send","local_id":1,"match_id":"generic_main"}
```

## Step 5: CHANNEL_REGISTERED 수신

```json
{"type":"CHANNEL_REGISTERED","channel_id":21,"local_id":1}
```

## Step 6: READY

```json
{"type":"READY","channel_id":21}
```

## Step 7: ROUTE 수신

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

## Step 8: UDP 전송

Endpoint가 정의한 Generic datagram을 다음 주소로 직접 전송합니다.

```text
127.0.0.1:8060
```

`ROUTE_REMOVE`, disconnect 또는 replacement route가 해당 state를 무효화할 때까지 사용합니다.

---

# 17. 최소 Generic Receiver 시퀀스

## Step 1: HELLO

```json
{"type":"HELLO","protocol_version":1,"endpoint_type":"external","capabilities":["generic_data_receive"]}
```

## Step 2: ASSIGN

Endpoint/session identity를 수신합니다.

## Step 3: CHANNEL_ADD

```json
{"type":"CHANNEL_ADD","channel_type":"generic_data_receive","local_id":1,"match_id":"generic_main"}
```

## Step 4: CHANNEL_REGISTERED

`channel_id`를 저장합니다.

## Step 5: PORT_ASSIGN

```json
{"type":"PORT_ASSIGN","channel_id":22,"port":8060}
```

UDP bind를 시도합니다.

### 성공

```json
{"type":"READY","channel_id":22,"port":8060}
```

### 실패

```json
{"type":"PORT_FAIL","channel_id":22,"port":8060,"reason":"bind failed"}
```

## Step 6: ROUTE

양쪽이 모두 READY가 되면 route metadata를 저장하고 UDP 수신을 시작합니다.

---

# 18. 최소 Python Control Client Skeleton

다음 코드는 framing과 handshake pattern만 보여 줍니다. 의도적으로 완전한 production Endpoint SDK는 아닙니다.

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

Production Endpoint는 추가로 다음을 구현해야 합니다.

- reconnect 전략
- session state 초기화
- socket error 처리
- 비동기 read/write
- route 검증
- UDP bind/send lifecycle 관리
- 정상 종료 처리
- host application thread 규칙

---

# 19. 진단

유용한 G-HUB log pattern:

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

정상적인 Body C1-C5 destination 연결에서는 보통 다음과 같은 형태가 나타납니다.

```text
PORT_ASSIGN ... 8021
PORT_ASSIGN ... 8022
PORT_ASSIGN ... 8023
PORT_ASSIGN ... 8024
PORT_ASSIGN ... 8025
```

단, Endpoint 코드는 이 순서에 의존해서는 안 됩니다.

### 19.1 COPY LOG

G-HUB v1.1.0에는 현재 표시 중인 log를 clipboard로 복사하는 `COPY LOG`가 포함되어 있습니다.

Community support를 요청할 때 개발자는 다음 정보를 포함하는 것을 권장합니다.

```text
G-HUB version
Endpoint version
HELLO capabilities
relevant CHANNEL_ADD / PORT_ASSIGN / READY / ROUTE lines
failure lines
reconnect result
```

---

# 20. Community Endpoint 개발자를 위한 호환성 규칙

## MUST

- HELLO를 가장 먼저 전송
- G-HUB v1.1.0에서는 protocol version 1 사용
- newline-delimited UTF-8 JSON 사용
- capability 사용 전에 선언
- G-HUB를 port authority로 취급
- routing identity에 `match_id` 사용
- reconnect 후 새 endpoint/session/channel/route ID 처리
- ROUTE_REMOVE 시 route-local state 초기화
- disconnect 시 TCP close
- G-HUB에 대한 가정에 application semantics를 포함하지 않음

## MUST NOT

- Body/Facial/Generic destination port를 identity로 하드코딩하지 않음
- `endpoint_id`가 reconnect/restart 후에도 유지된다고 가정하지 않음
- 특정 공식 application만 source가 될 수 있다고 가정하지 않음
- 고주파 Data Plane packet을 RELAY로 보내지 않음
- 일반 Endpoint 호환성을 위해 private G-HUB class / field name / IL layout에 의존하지 않음
- 문서화되지 않은 내부 동작이 안정적으로 유지된다고 가정하지 않음

## SHOULD

- Community Endpoint에는 `endpoint_type=external` 사용
- 안정적이고 설명적인 `match_id` convention 사용
- route peer/session metadata 검증
- destination/source owner 대기 상태 허용
- G-HUB restart 없이 reconnect 구현
- bug report에 protocol log 포함
- Generic schema에 version 유지 (`vendor.schema.v1` 형식)

---

# 21. Security / Trust Boundary

G-HUB v1.1.0 Control Server는 local-loopback 기반 소프트웨어입니다.

이 protocol은 다음 기능을 제공하지 않습니다.

```text
TLS
remote authentication
endpoint certificates
per-message signatures
permission scopes
```

`session_id`는 routing/lifecycle identity이며 authentication secret이 아닙니다.

Community 개발자는 forwarding/proxying으로 Control Server를 신뢰할 수 없는 네트워크에 노출한 뒤 v1 protocol이 network security를 제공한다고 가정해서는 안 됩니다.

Remote/networked URSS transport에는 별도의 security design이 필요합니다.

---

# 22. 알려진 v1.1.0 경계

다음 항목은 Endpoint Contract의 버그가 아니라 의도적으로 설정된 현재의 경계입니다.

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

Community fork는 이 경계를 넘어 실험할 수 있지만, 그러한 동작이 자동으로 Vanilla 호환성의 일부가 되는 것은 아닙니다.

---

# 23. Unknown Endpoint Test

Extension을 설계할 때 다음 질문을 사용하십시오.

> TeamGadget조차 존재를 모르는 미래의 Endpoint X가 이 문서만 읽고 G-HUB에 참여할 수 있는가?

답을 위해 다음이 필요하다면:

```text
editing G-HUB
knowing a private class name
hard-coding an internal field
assuming Cascadeur/Unity/Blender/Godot by name
```

그 설계는 아마 application-specific이며 Platform Contract가 아니라 Endpoint에 속해야 합니다.

---

# 24. 권장 External Endpoint 검증

G-HUB v1.1.0 호환성을 선언하기 전에 최소한 다음을 테스트하십시오.

### Registration

- HELLO -> ASSIGN
- 지원하지 않는 protocol 거부
- reconnect 시 새로운 identity 수신

### Channel

- CHANNEL_ADD -> CHANNEL_REGISTERED
- 선언하지 않은 capability 거부
- 중복 local channel 등록이 거부되거나 중복을 생성하지 않음

### Receiver

- PORT_ASSIGN
- bind -> READY
- PORT_FAIL 경로

### Routing

- 정확히 1 sender + 1 receiver일 때 route 성립
- 동일한 `match_id` 필요
- match conflict 시 route 미생성
- ROUTE_REMOVE가 local state를 초기화

### Ownership

- Body Source contender는 대기
- owner disconnect 시 대기 source 승격
- Destination contender는 대기
- owner disconnect 시 대기 destination 승격

### Generic

- Generic은 Body Source ownership을 점유하지 않고 Body / Facial source와 공존 가능
- Generic receiver도 동일한 Destination ownership model에 참여
- Endpoint 레벨에서 여러 object/schema가 하나의 Generic route를 공유 가능

### Timeline

- sync request
- local owner claim
- owner tick
- non-owner tick 무시
- release
- owner disconnect 시 마지막 position에서 pause

### Cleanup

- stale UDP bind 없음
- stale route 없음
- G-HUB restart 없이 reconnect 성공

---

# 25. Public Contract와 Internal Implementation

Community 호환성은 다음을 기준으로 해야 합니다.

```text
this documented Control Protocol
published Data Plane contracts
published Generic schema/envelope contracts
official Vanilla Endpoint behavior
```

다음에 의존해서는 안 됩니다.

```text
private C# class names
reflection into private members
IL offsets
method count
binary patch points
undocumented internal state
```

Binary modification은 유용한 Community 실험이 될 수 있지만, 일반 URSS Endpoint 개발과는 다른 compatibility layer이며 `external`을 통해 참여하기 위해 필요하지 않습니다.

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

# 27. 최종 원칙

G-HUB v1.1.0은 의도적으로 semantic responsibility를 작게 유지합니다.

G-HUB가 알아야 하는 것은 **데이터가 어디로 가는지, 누가 route를 소유하는지, lifecycle이 유효한지**입니다.

반대로 **검, camera, humanoid, quadruped, light, constraint, Blender Object, Unity GameObject, Godot Node 또는 미래의 application object가 무엇을 의미하는지**는 알 필요가 없습니다.

이 분리가 있기 때문에 Community Endpoint 구현이 독립적으로 발전해도 URSS는 안정성을 유지할 수 있습니다.

---

**URSS G-HUB v1.1.0 개발자 기술 레퍼런스 끝**
