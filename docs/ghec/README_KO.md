# GHEC v1.0.2 — G-HUB Entangle for Cascadeur

**G-HUB Entangle for Cascadeur (GHEC)**는 G-HUB를 통해 Cascadeur와 함께 사용하도록 설계된 독립적인 TeamGadget 동기화 컴포넌트입니다.

GHEC는 Cascadeur를 **TeamGadget Universal Real-Time Sync System**에 연결하고, 실시간 Character 동기화, 명시적 Character Slot 할당, Route 단위 Multi-Character 동기화, Canonical Timeline 동기화를 제공합니다.

> GHEC v1.0.2는 명시적 Character Assignment를 사용합니다. 각 URSS Character Slot을 Cascadeur의 Character Branch에 직접 연결할 수 있으므로, 더 이상 Character Identity가 Bone Name Prefix에 의존하지 않습니다.

---

## 개요

GHEC는 TeamGadget 동기화 시스템의 Cascadeur 측 컴포넌트입니다.

GHEC는 Unity, Blender, ShapeMixer Entangle 또는 기타 애플리케이션과 **직접 통신하지 않습니다**.  
모든 Routing과 Synchronization은 **G-HUB**를 통해 처리됩니다.

```text
Cascadeur / GHEC
       │
       ▼
     G-HUB
      ├── GHEU — G-HUB Entangle for Unity
      ├── GHEB — G-HUB Entangle for Blender
      └── SE   — ShapeMixer Entangle
```

![Launch GHEC from the Cascadeur Scripts menu](images/ghec-main.png)

## 요구 사항

### 검증 환경

- **Cascadeur 2026.2.2**
- **Windows 64-bit**
- **G-HUB v1.0**

### Cascadeur License 요구 사항

GHEC를 사용하려면 유료 Cascadeur License가 필요합니다.

지원되는 Cascadeur License Tier:

- Indie
- Pro
- Teams

무료 버전의 Cascadeur는 GHEC에서 지원되지 않습니다.

---

## 설치

GHEC는 Cascadeur의 Python Script 및 Python Model 디렉터리를 사용합니다.

### 1. GHEC Script 설치

다음 파일을 복사합니다.

```text
ghec.py
```

다음 위치로 복사하십시오.

```text
<Cascadeur installation folder>/resources/scripts/python/scripts/
```

예:

```text
C:/Program Files/Cascadeur/resources/scripts/python/scripts/
```

### 2. GHEC Model 파일 설치

다음 폴더가 없다면 생성합니다.

```text
<Cascadeur installation folder>/resources/scripts/python/models/ghec/
```

다음 파일들을 해당 폴더에 복사합니다.

```text
backend.pyc
model.py
view.qml
```

최종 폴더 구조는 다음과 같습니다.

```text
resources/
└─ scripts/
   └─ python/
      ├─ scripts/
      │  └─ ghec.py
      │
      └─ models/
         └─ ghec/
            ├─ backend.pyc
            ├─ model.py
            └─ view.qml
```

### 3. GHEC 실행

파일 설치 후 Cascadeur를 재시작합니다.

상단 **Scripts** 메뉴를 열고 다음 항목을 선택합니다.

**G-HUB Entangle for Cascadeur**

![Launch GHEC from the Cascadeur Scripts menu](images/ghec-scripts-menu.png)

> GHEC v1.0.2 Documentation은 Cascadeur 2026.2.2를 기준으로 작성되었습니다.

---

## 빠른 시작

1. **G-HUB**를 실행합니다.
2. **Cascadeur**를 실행합니다.
3. Cascadeur의 **Scripts** 메뉴에서 **G-HUB Entangle for Cascadeur**를 선택합니다.
4. GHEC를 연 뒤 Scene이 변경되었다면 **REFRESH**를 눌러 사용 가능한 Cascadeur Character Branch를 다시 검색합니다.
5. 사용할 각 URSS Character Slot에서 해당 Cascadeur Character Branch를 Drop-down 목록으로 선택합니다.
6. 필요한 Character Slot을 활성화합니다.
7. Slot Assignment에 저장되지 않은 변경 사항이 표시되면 **SAVE**를 누른 뒤, Cascadeur `.cas` Scene도 일반적인 방법으로 저장합니다.
8. G-HUB Control Port가 G-HUB와 동일한지 확인합니다.
9. **CONNECT**를 누릅니다.
10. Destination TeamGadget Endpoint를 연결하고 동일한 Character Slot을 사용합니다.
11. Canonical Timeline 동기화가 필요한 경우에만 **Timeline Sync**를 활성화합니다.

GHEC가 연결되면 상태가 **CONNECTED**로 변경되고 Endpoint ID가 표시되며, 연결 해제 전까지 Character Slot 설정이 잠깁니다.

![Launch GHEC from the Cascadeur Scripts menu](images/ghec-main.png)

> Character Assignment는 Scene에 저장되는 상태입니다. `SAVE`는 GHEC가 사용하는 Slot Assignment를 저장하며, `.cas` Scene을 저장하면 재시작 후에도 해당 Assignment를 유지할 수 있습니다.

---

## G-HUB Connection

GHEC는 설정된 Control Port를 통해 G-HUB Control Plane에 연결합니다.

기본값:

```text
127.0.0.1:8000
```

기본 설정은 동일한 Windows PC 내에서 통신하기 위한 것입니다.

G-HUB에서 Control Port를 변경했다면, 연결하기 전에 GHEC에도 동일한 Control Port를 입력하십시오.

---

## Character Slots

GHEC는 최대 **5 Character Slots**을 지원합니다.

| GHEC Slot | URSS Route |
| --- | --- |
| Character 1 | `char_01` |
| Character 2 | `char_02` |
| Character 3 | `char_03` |
| Character 4 | `char_04` |
| Character 5 | `char_05` |

### Explicit Character Assignment

GHEC v1.0.2는 활성화된 각 URSS Slot을 Cascadeur Character Branch에 직접 할당합니다.

선택된 Slot은 해당 Character의 Joint Set을 소유합니다. 따라서 Destination Endpoint는 `character1:`, `character2:` 같은 Prefix를 추가하지 않고 원래 Joint Name을 요청할 수 있습니다.

일반적인 설정 순서:

1. 필요한 경우 **REFRESH**를 눌러 Character Root Joint Branch를 다시 검색합니다.
2. Slot Drop-down에서 대상 Cascadeur Character를 선택합니다.
3. Slot을 활성화합니다.
4. Assignment가 Unsaved 상태로 표시되면 **SAVE**를 누릅니다.
5. `.cas` Scene을 저장합니다.
6. GHEC를 연결합니다.

Assignment Line에는 현재 상태가 표시됩니다. 예를 들어 소유 중인 Joint 수와 선택한 Branch Name이 함께 표시되는 Explicit Assignment 상태를 확인할 수 있습니다.

### Legacy Compatibility

구형 Prefix 기반 Lookup은 v1.0.2 이전 Workflow와의 호환성을 위해서만 유지됩니다. 더 이상 권장되는 Character Identity 방식이 아닙니다.

새 Endpoint 구현에서는 URSS Route / Character Slot을 Character Identity로 사용하고, 해당 Route 내부에서는 원래 Bone / Joint Name을 사용해야 합니다.

> Character Slot Assignment 및 Enable / Disable Control은 연결 해제 상태에서만 편집할 수 있습니다. 변경 전 GHEC를 연결 해제하십시오.

---

## Character Synchronization

GHEC는 Live Streaming 시작 전에 Initialization 및 Handshake 단계를 사용합니다.

연결 과정에서 동기화에 필요한 Character Structure가 G-HUB를 통해 교환됩니다.

Route가 준비되면 할당된 G-HUB UDP Channel을 통해 Live Character Data가 Streaming됩니다.

### Rig-Agnostic Workflow

TeamGadget 동기화 Architecture는 양쪽에 호환 가능한 Character Structure가 있는 경우, 사용자가 직접 Bone Mapping을 작성하지 않아도 되도록 설계되었습니다.

연결된 애플리케이션은 Initialization 단계에서 자신의 Character Structure를 제공하며, Destination 컴포넌트가 내부적으로 Local Mapping을 해결합니다.

따라서 CC 전용 또는 Humanoid 전용 Pipeline에 고정되지 않고, 다양한 Rig Type에서 동일한 Synchronization Workflow를 사용할 수 있습니다.

실제 호환성은 연결된 애플리케이션에서 제공되는 Hierarchy와 Character Data에 따라 달라집니다.

---

## Timeline Synchronization

GHEC는 G-HUB Canonical Timeline Synchronization System에 참여할 수 있습니다.

**Timeline Sync**를 활성화하면 Cascadeur는 G-HUB를 통해 다른 참여 TeamGadget 컴포넌트와 Timeline State를 교환할 수 있습니다.

연결된 컴포넌트에 따라 동기화되는 Timeline State에는 다음이 포함될 수 있습니다.

- Current Frame
- Play
- Pause
- Stop
- Scrub / Seek
- Timeline Range
- Frame Rate

Timeline 동기화는 선택 사항입니다.

---

## User Interface

GHEC Window에는 일반적인 사용에 필요한 Control이 포함되어 있습니다.

### G-HUB

현재 G-HUB 연결 상태를 표시합니다.

- **Control** — G-HUB Control Address 및 Port
- **CONNECT / DISCONNECT** — GHEC를 G-HUB에 연결하거나 연결 해제합니다.
- **Connection Status** — GHEC의 연결 여부를 표시합니다.

### Character Slots

Character 1부터 Character 5까지 표시합니다.

각 Row에는 다음 항목이 있습니다.

- Cascadeur Character Branch Selector
- URSS Route Identifier (`char_01` ~ `char_05`)
- Enable / Disable Control
- 현재 Assignment 상태

Character Slots 영역에는 다음 기능도 포함됩니다.

- **REFRESH** — 사용 가능한 Cascadeur Character Root Joint Branch를 다시 검색합니다.
- **SAVE** — 일반적인 `.cas` Scene 저장 전에 변경된 Slot Assignment를 저장합니다.

Explicit Character Assignment가 v1.0.2의 기본 Workflow입니다. Legacy Prefix Fallback은 오래된 Project 및 Endpoint와의 호환성을 위해서만 유지됩니다.

### Timeline Sync

G-HUB Canonical Timeline Synchronization 참여 여부를 제어합니다.

활성화하면 GHEC는 G-HUB를 통해 다른 참여 TeamGadget 컴포넌트와 Timeline State를 교환할 수 있습니다.

### Close

GHEC Window를 닫습니다.

Panel을 닫아도 GHEC 연결은 **해제되지 않습니다**. 이미 연결된 상태라면 명시적으로 Disconnect할 때까지 연결이 유지됩니다.

---

## 배포

권장 v1.0.2 Release Archive:

```text
GHEC_v1.0.2_Windows_x64.zip
```

GHEC는 Mixed Distribution Model을 사용합니다.

### Open-Source Components

다음 파일은 Source 형태로 배포됩니다.

```text
ghec.py
model.py
view.qml
```

### Compiled Backend

다음 컴포넌트는 Compiled 형태로만 배포됩니다.

```text
backend.pyc
```

`backend.pyc`에는 GHEC에서 사용하는 Cascadeur License Validation을 포함한 보호된 Backend 기능이 포함되어 있습니다.

Compiled Backend는 GHEC의 Open-source 부분에 **포함되지 않습니다**.

---

## 문제 해결

### Cascadeur에 GHEC가 표시되지 않는 경우

다음을 확인하십시오.

- `ghec.py`가 Cascadeur Python `scripts` 디렉터리에 설치되어 있는지
- `backend.pyc`, `model.py`, `view.qml`이 `models/ghec`에 설치되어 있는지
- 설치 후 Cascadeur를 재시작했는지
- **Scripts** 메뉴에서 **G-HUB Entangle for Cascadeur**를 실행하고 있는지

### GHEC가 G-HUB에 연결되지 않는 경우

다음을 확인하십시오.

- G-HUB가 실행 중인지
- GHEC와 G-HUB가 동일한 Control Port를 사용하는지
- 다른 애플리케이션이 설정된 Port를 이미 사용 중인지
- Windows Firewall 또는 보안 소프트웨어가 Local Communication을 차단하고 있지 않은지

### Character Slot이 동기화되지 않는 경우

다음을 확인하십시오.

- 해당 Character Slot이 GHEC에서 활성화되어 있는지
- 대응하는 Destination 컴포넌트가 G-HUB에 연결되어 있는지
- 양쪽 애플리케이션이 동일한 Character Slot을 사용 중인지
- G-HUB에서 Route가 Active 상태인지

### Timeline Sync가 동작하지 않는 경우

다음을 확인하십시오.

- GHEC가 G-HUB에 연결되어 있는지
- Timeline Sync가 활성화되어 있는지
- 다른 참여 TeamGadget 컴포넌트가 Canonical Timeline Path에 연결되어 있는지

---

## License

GHEC는 Open-source 부분과 Compiled 컴포넌트에 서로 다른 License를 적용합니다.

### Open-Source Files

Open-source 부분에는 다음 문서가 적용됩니다.

```text
LICENSE
```

### Compiled Backend

다음 Compiled 컴포넌트:

```text
backend.pyc
```

에는 별도로 다음 문서가 적용됩니다.

```text
EULA.md
```

해당되는 경우 사용자는 두 문서의 조건을 모두 준수해야 합니다.

---

## Third-Party Notice

GHEC는 Cascadeur와 함께 사용하도록 설계된 독립적인 **TeamGadget** 프로젝트입니다.

TeamGadget은 Cascadeur 개발자 또는 소유자와 제휴, 승인, 후원, 인증 또는 공식 지원 관계에 있지 않습니다.

Cascadeur 및 관련 Product Name과 Trademark는 각 권리자에게 귀속됩니다.

---

## Project

**TeamGadget**  
**GHEC — G-HUB Entangle for Cascadeur v1.0.2**
