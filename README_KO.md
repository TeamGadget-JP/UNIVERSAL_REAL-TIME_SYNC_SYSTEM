>## 다운로드
>
>[GitHub Releases](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases).
>
>## 독립 실행형 애플리케이션 (압축 해제 필요)
>*   **[G-HUB v1.0.0](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases/download/g-hub-v1.0.0/G-HUB_v1.0_Windows_x64.zip)**  
>    Universal Real-Time Sync System을 사용하기 위해 필요합니다.  
>    **설치 방법:** 파일의 압축을 해제하십시오. 독립 실행형 애플리케이션입니다.
>*   **[ShapeMixerEntangle v1.0.0](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases/download/se-v1.0.0/ShapeMixer_Entangle_v1.0_Windows_x64.zip)**  
>    Facial / Shape Key 제작용 Endpoint입니다.  
>    **설치 방법:** 파일의 압축을 해제하십시오. 독립 실행형 애플리케이션입니다.
>
>## Blender (⚠️ 압축 해제 금지)
>*   **[GHEB v1.0.1](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases/download/gheb-v1.0.1/GHEB_v1_0_1_Blender5_2LTS.zip)**  
>    Blender 5.2 LTS용 Endpoint입니다.  
>    **설치 방법:** ⚠️ **압축을 해제하지 마십시오.** `.zip` 파일을 다운로드한 뒤 Blender의 Add-on / Extension 환경설정에서 그대로 설치하십시오.
>
>## 게임 엔진 및 DCC 도구 (압축 해제 필요)
>*   **[GHEC v1.0.2](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases/download/ghec-v1.0.2/GHEC_v1.0.2_Windows_x64.zip)**  
>    Cascadeur 2026.2용 Endpoint입니다.  
>    **설치 방법:** 파일의 압축을 해제한 뒤 지정된 플러그인 디렉터리에 폴더를 수동으로 배치하십시오.
>*   **[GHEU v1.0.1](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases/download/gheu-v1.0.1/GHEU_v1.0.1_6.3LTS.unitypackage)**  
>    Unity 6.3 LTS용 Endpoint입니다.  
>    **설치 방법:** 압축된 경우 압축을 해제한 뒤, 일반적인 `.unitypackage` 가져오기 방식으로 설치하십시오.
>*   **[GHEG v1.0.0](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases/download/gheg-v1.0.0/GHEG_v1.0.0_Godot4.7.NET_RELEASE.zip)**  
>    Godot 4.7 .NET용 Endpoint입니다.  
>    **설치 방법:** 파일의 압축을 해제한 뒤 지정된 플러그인 디렉터리에 폴더를 수동으로 배치하십시오.

![TeamGadget Unity Workflow](docs/images/urss-top.png)

현재 URSS Suite는 다음 기능을 제공합니다.

- 실시간 Body 동기화
- 실시간 Facial / Shape Key 동기화
- 최대 **5개의 Character Slot**
- 중앙 집중식 Route 관리
- Canonical Timeline 동기화
- 지원되는 Body Endpoint용 Rig-Agnostic / Smart Swizzle 워크플로
- Unity, Blender, Godot용 Offline Facial Animation Bake
- Blender Action으로 직접 출력하는 Offline Body Animation Bake
- Unity 및 Godot용 FBX Bridge Body Animation 전송 워크플로
- ShapeMixer Entangle을 통한 전용 Facial Animation 제작 환경

---

## Unity Workflow

현재 Unity Endpoint: **GHEU v1.0.1**

Unity 워크플로는 다음 구성요소를 조합합니다.

- Body Animation용 **Cascadeur + GHEC**
- Facial / BlendShape Animation용 **ShapeMixer Entangle**
- Routing 및 Canonical 동기화용 **G-HUB**
- Unity Endpoint인 **GHEU**

![TeamGadget Unity Workflow](docs/images/unity_workflow.png)

Unity 제작 워크플로:

![TeamGadget Unity Workflow](docs/images/GHEU-workflow.png)

실시간 Body 및 Facial 동기화도 동일한 G-HUB Session을 통해 실행할 수 있습니다.

Offline Facial Bake에서는 Source와 Destination의 Frame Rate가 같을 필요가 없습니다. GHEU는 Canonical Time을 유지하고 각 Output Frame을 대응하는 SE Source Time에 맞춰 해석합니다.

---

## Blender Workflow

현재 Blender Endpoint: **GHEB v1.0.1**

Blender 워크플로는 다음 구성요소를 조합합니다.

- Body Animation용 **Cascadeur + GHEC**
- Facial / Shape Key Animation용 **ShapeMixer Entangle**
- Routing 및 Canonical 동기화용 **G-HUB**
- Blender Endpoint인 **GHEB**

![TeamGadget Blender Workflow](docs/images/blender_workflow.png)

Blender 제작 워크플로:

![TeamGadget Unity Workflow](docs/images/GHEB-workflow.png)

실시간 Body 및 Facial 동기화는 동일한 GHEB Endpoint를 통해 실행할 수 있습니다.

Offline Bake에서는 Source와 Destination의 Frame Rate가 같을 필요가 없습니다. GHEB는 Canonical Time을 유지하고 각 Blender Output Frame을 대응하는 Routed Source Time에 맞춰 해석합니다.

---

## Godot Workflow

현재 Godot Endpoint: **GHEG v1.0.0**

Godot 워크플로는 다음 구성요소를 조합합니다.

- Body Animation용 **Cascadeur + GHEC**
- Facial / Blend Shape Animation용 **ShapeMixer Entangle**
- Routing 및 Canonical 동기화용 **G-HUB**
- Godot .NET Endpoint인 **GHEG**

![TeamGadget Godot Workflow](docs/images/godot_workflow.png)

Godot 제작 워크플로:

![TeamGadget Unity Workflow](docs/images/GHEG-workflow.png)

GHEG는 실시간 Body / Facial 동기화, 5개의 Character Slot, Canonical Timeline 동기화, Smart Swizzle 진단, FBX Bridge Import, Offline Facial Animation Bake를 지원합니다.

이 Endpoint는 Body 및 Facial Animation Asset을 Godot Project 내부로 전달합니다. 해당 Asset을 실제 Production Character Scene에 최종 적용하는 작업은 사용자가 제어하는 일반적인 Godot 제작 단계로 남겨 둡니다.

---

## Components

| Component | Current Version | Role | Distribution |
| --- | --- | --- | --- |
| **G-HUB** | v1.0 | 중앙 통신, Routing, Character Slot, Canonical Timeline | Windows x64용 사전 빌드 애플리케이션 |
| **GHEC** | v1.0.2 | Cascadeur Endpoint | 혼합 배포: Source File + 컴파일된 보호 Backend |
| **GHEU** | v1.0.1 | Unity Endpoint | Open Source + Unity Package |
| **ShapeMixer Entangle (SE)** | v1.0 | Facial / Shape Key 제작 및 동기화 | Windows x64용 사전 빌드 애플리케이션 |
| **GHEB** | v1.0.1 | Blender Endpoint | Open-source Blender Add-on |
| **GHEG** | v1.0.0 | Godot .NET Endpoint | Source로 배포되는 TeamGadget Endpoint |

---

## Current Components

### G-HUB v1.0

**Universal Real-Time Sync Hub**

G-HUB는 시스템의 중심입니다.

다음을 관리합니다.

- Endpoint 등록
- Character Slot Routing
- Body / Facial Channel
- Route 생성 및 제거
- Canonical Timeline의 Ownership 및 배포
- 설정 가능한 Local Network 옵션
- Runtime Channel / Route 모니터링

문서:

[`docs/g-hub/README.md`](docs/g-hub/README.md)

---

### GHEC v1.0.2

**G-HUB Entangle for Cascadeur**

GHEC는 Cascadeur를 G-HUB에 연결하며 다음 기능을 제공합니다.

- 실시간 Character Streaming
- 최대 5개의 Character Slot
- `char_01`부터 `char_05`까지의 명시적 Character Assignment
- Scene에 저장되는 Character Slot Assignment
- Smart Swizzle / Reference Pose 교환
- Canonical Timeline 동기화
- 지원되는 Destination Endpoint에서 사용하는 Bridge Workflow
- 이전 Workflow를 위한 Legacy Prefix 호환성

GHEC를 사용하려면 지원되는 유료 Cascadeur License가 필요합니다.

Release Package:

```text
GHEC_v1.0.2_Windows_x64.zip
```

문서:

[`docs/ghec/README.md`](docs/ghec/README.md)

---

### GHEU v1.0.1

**G-HUB Entangle for Unity**

GHEU는 Unity를 G-HUB에 연결하며 다음 기능을 제공합니다.

- 실시간 Body 동기화
- Humanoid / Generic Workflow
- Rig-Agnostic 동기화
- Smart Swizzle 진단
- 설정 가능한 Local Position Scale
- Root Motion 및 Interpolation 제어
- 실시간 Facial / BlendShape 동기화
- Multi-Character Routing
- Canonical Timeline 동기화
- GHEU Offline Facial Bake
- FBX Bridge Body Animation 전송

지원 Unity Version:

- **Unity 6.3 LTS**
- Windows 64-bit
- Release Package: `GHEU_v1.0.1_6.3LTS.unitypackage`

GHEU는 Unity 6.3 LTS를 기준으로 개발 및 검증되었습니다. 그 외 Unity Version은 이번 Release에서 공식 지원 대상이 아닙니다.

문서:

[`docs/gheu/README.md`](docs/gheu/README.md)

---

### GHEB v1.0.1

**G-HUB Entangle for Blender**

GHEB는 Blender를 G-HUB에 연결하며 다음 기능을 제공합니다.

- 실시간 Body 동기화
- 실시간 Facial / Shape Key 동기화
- 최대 5개의 Character Slot
- Body + Facial 동시 동기화
- Rig-Agnostic / Smart Swizzle Body Workflow
- Floating Smart Swizzle 진단
- 선택 가능한 Body Interpolation
- 설정 가능한 Translation Scale
- Canonical Timeline 동기화
- Blender Armature Action으로의 Offline Body Bake
- Multi-Mesh Facial 동기화 및 Bake
- Multi-Character Facial Bake

지원 Blender Version:

- **Blender 5.2 LTS**
- Windows 64-bit
- Release Package: `GHEB_v1_0_1_Blender5_2LTS.zip`

GHEB는 Blender 5.2 LTS를 기준으로 개발 및 검증되었습니다. 그 외 Blender Version은 이번 Release에서 공식 지원 대상이 아닙니다.

문서:

[`docs/gheb/README.md`](docs/gheb/README.md)

---

### GHEG v1.0.0

**G-HUB Entangle for Godot**

GHEG는 Godot .NET을 G-HUB에 연결하며 다음 기능을 제공합니다.

- 실시간 Body 동기화
- 실시간 Facial / Blend Shape 동기화
- 최대 5개의 Character Slot
- `AUTO ASSIGN` 및 `ASSIGN ALL`을 통한 명시적이고 안전한 Setup Assistance
- Rig-Agnostic / Smart Swizzle Body Workflow
- SS Visualizer 진단
- Canonical Timeline 동기화
- URSS Timeline Transport 전용 GHEG Transport Node
- FBX Bridge Body Animation 전송 및 Godot Import
- Godot Animation Resource로의 Offline Facial Bake
- 설정 가능한 Local Position Scale

검증된 환경:

- **Godot 4.7.2 .NET**
- Windows 64-bit
- Release Package: `GHEG_v1.0.0_Godot4.7.NET_RELEASE.zip`

GHEG 설정에는 Godot 측의 여러 Node와 Reference가 필요합니다. 전용 GHEG 문서에는 완전한 C1 Step-by-Step Setup Guide, 신규 Project의 .NET 초기화 주의사항, Node Structure 가이드 및 Troubleshooting이 포함되어 있습니다.

문서:

[`docs/gheg/README.md`](docs/gheg/README.md)

---

### ShapeMixer Entangle v1.0

**Facial / Shape Key Authoring Endpoint**

ShapeMixer Entangle은 전용 Facial Animation Tool로 다음 기능을 제공합니다.

- FBX / glTF Shape Key Import
- Layered XY Pad
- Additional Shape Key Control
- Preset
- Multi-Take Animation
- Bezier Curve Editing
- Audio Waveform Reference
- 최대 5개의 Character Slot
- 실시간 G-HUB Facial 동기화
- Canonical Timeline 동기화
- 지원 Endpoint용 Offline Facial Bake Workflow

문서:

[`docs/se/README.md`](docs/se/README.md)

---

## Character Slots

시스템은 최대 **5개의 Character Slot**을 지원합니다.

```text
C1 → char_01
C2 → char_02
C3 → char_03
C4 → char_04
C5 → char_05
```

Character Slot은 여러 Character가 활성화되어 있을 때도 Body, Facial, Bake, Timeline 관련 데이터를 서로 분리해서 유지합니다.

현재 Routing Contract에서는 **URSS Route / Character Slot 자체를 Character Identity로 취급합니다**. Bone 및 Joint 이름은 해당 Route 내부 Character의 로컬 이름으로 유지됩니다.

GHEC v1.0.2에서는 이 Contract를 위해 명시적인 Cascadeur Character Assignment를 도입했으며, 기존 Project를 위해 Legacy Prefix 호환성도 유지합니다.

---

## Canonical Timeline Synchronization

G-HUB는 현재 Production Endpoint 사이에서 **완전한 양방향 Timeline 동기화**를 제공합니다.

- **Cascadeur / GHEC**
- **Unity / GHEU**
- **Blender / GHEB**
- **Godot / GHEG**
- **ShapeMixer Entangle / SE**

참여 중인 어떤 Endpoint라도 Timeline을 구동할 수 있으며, 연결된 다른 Endpoint들은 G-HUB를 통해 동일한 Canonical Playback State를 따릅니다.

동기화되는 State에는 다음이 포함됩니다.

- Current Time / Frame Position
- Play
- Pause
- Stop
- Scrub / Seek
- Playback Range
- Frame Rate

### FPS가 달라도 Time은 Canonical하게 유지됩니다

동기화 모델은 단순히 동일한 Frame 번호가 아니라 **Time**을 유지합니다.

다시 말해:

> **모든 Endpoint에서 1초는 항상 1초입니다.**

연결된 Application의 Frame Rate가 서로 다르면, 각 Endpoint는 공유된 Canonical Time을 자신의 Local Frame Position으로 변환합니다.

예:

```text
30 FPS endpoint → Frame 30 = 1.0 second
60 FPS endpoint → Frame 60 = 1.0 second
```

따라서 화면에 표시되는 Frame 번호가 달라도 Animation Time은 동기화된 상태를 유지합니다.

이를 통해 Cascadeur, Unity, Blender, Godot, ShapeMixer Entangle은 각자의 Local FPS 설정이 달라도 서로 동기화된 상태를 유지할 수 있습니다.

Timeline 동기화는 양방향입니다. Play, Pause, Stop, Scrub / Seek, Range 변경, Timeline Position은 G-HUB를 통해 전달되어 참여 Endpoint들이 계속 일치된 상태를 유지합니다.

---

## Design Principles

이 Suite는 몇 가지 핵심 원칙을 중심으로 설계되었습니다.

### Centralized Routing

모든 Application 조합마다 Point-to-Point Integration을 따로 구현하는 대신, Endpoint는 G-HUB를 통해 통신합니다.

### One Active Destination Route

URSS는 **Cascadeur + ShapeMixer Entangle ↔ 한 번에 하나의 Destination Endpoint**를 기본 설계로 합니다.

Unity, Blender, Godot 및 기타 Destination Endpoint로 동시에 Streaming할 필요가 없습니다. 이를 통해 Route Ownership과 동기화 동작을 명확하고 결정적으로 유지할 수 있습니다.

### Character-Slot Isolation

각 Character는 Logical Slot에 할당되므로 여러 Character가 활성화되어 있어도 Body / Facial Data가 서로 섞이지 않습니다.

### Rig-Agnostic Body Synchronization

지원되는 Body Endpoint는 Structure 및 Reference Pose 정보를 교환하므로, 호환 가능한 Rig마다 사용자가 Bone Mapping을 수동으로 생성할 필요가 없습니다.

### Smart Swizzle

Smart Swizzle은 각 Application 고유의 Rig Convention을 유지하면서, 연결된 Character Structure 사이의 Reference Pose 및 Local Axis 차이를 해결합니다.

### Single-Target Offline Bake

Offline Bake Workflow는 의도적으로 한 번에 하나의 Target에 대해서만 수행됩니다. 이를 통해 Bake Ownership을 명확하게 유지하고, Batch 처리의 복잡성보다 신뢰성을 우선합니다.

### Separate Body and Facial Production Paths

적절한 경우 Body / Facial Animation은 모든 데이터를 하나의 Export 방식에 강제로 통합하지 않고, 각각의 전용 Production Workflow를 사용합니다.

Unity:

- **Body asset:** FBX Bridge
- **Facial asset:** SE → G-HUB → GHEU Offline Facial Bake

Blender:

- **Body asset:** GHEC → G-HUB → GHEB Offline Body Bake → Armature Action
- **Facial asset:** SE → G-HUB → GHEB Offline Facial Bake → Shape Key Action

Godot:

- **Body asset:** FBX Bridge → Godot-imported animation
- **Facial asset:** SE → G-HUB → GHEG Offline Facial Bake → Godot Animation resource

---

## Repository Structure

```text
UNIVERSAL_REAL-TIME_SYNC_SYSTEM/
├─ README.md
└─ docs/
   ├─ images/
   │  ├─ unity_workflow.png
   │  ├─ blender_workflow.png
   │  └─ godot_workflow.png
   │
   ├─ g-hub/
   │  ├─ images/
   │  ├─ LICENSE.txt
   │  └─ README.md
   │
   ├─ ghec/
   │  ├─ images/
   │  ├─ EULA.md
   │  ├─ LICENSE
   │  └─ README.md
   │
   ├─ gheu/
   │  ├─ images/
   │  ├─ LICENSE
   │  └─ README.md
   │
   ├─ gheb/
   │  ├─ images/
   │  ├─ LICENSE
   │  └─ README.md
   │
   ├─ gheg/
   │  ├─ images/
   │  ├─ LICENSE.txt
   │  └─ README.md
   │
   └─ se/
      ├─ images/
      ├─ LICENSE
      └─ README.md
```

Component Source 및 Release Asset은 각 Component의 Distribution Model에 따라 정리되어 있습니다.

---

## Licensing

각 Component에는 고유한 License 및 Distribution Terms가 있습니다.

관련 Component에 포함된 `LICENSE`, `LICENSE.txt`, 또는 `EULA.md`를 확인하십시오.

일반적으로:

- **G-HUB** — TeamGadget proprietary binary distribution
- **ShapeMixer Entangle** — TeamGadget proprietary binary distribution
- **GHEC** — Mixed distribution. Source File과 컴파일된 Proprietary Backend는 각각 별도의 License가 적용됩니다
- **GHEU** — Open-source Unity Endpoint
- **GHEB** — Open-source Blender Endpoint
- **GHEG** — 자체 License 조건에 따라 Source로 배포되는 TeamGadget Godot Endpoint

Third-party Library 및 Runtime에는 각각의 License와 Notice가 적용됩니다.

---

## Third-Party Notice

이 Repository에는 Third-party Application 및 File Format과의 상호 운용을 위해 설계된 독립적인 **TeamGadget** Project가 포함되어 있습니다.

명시적으로 별도 표기된 경우를 제외하고, TeamGadget은 Cascadeur, Unity, Blender, Godot 또는 그 밖에 언급된 Third-party Product의 개발사나 소유사와 제휴, 승인, 후원, 인증 또는 공식 지원 관계가 없습니다.

모든 Third-party Product Name 및 Trademark는 해당 권리자의 소유입니다.

---

## Logo and Trademark Notice

이 README의 Architecture Diagram 및 Workflow Illustration에는 **Cascadeur, Unity, Blender, Godot**를 포함한 Third-party Application의 Logo 및 Visual Identifier가 포함되어 있습니다.

이러한 Logo는 **Universal Real-Time Sync System (URSS)** 이 지원하는 Application을 식별하고 설명하기 위한 목적으로만 사용됩니다.

모든 Third-party Logo, Product Name, Trademark는 해당 권리자의 소유입니다.

이러한 Logo의 사용은 각 Trademark Owner가 TeamGadget 또는 URSS와 제휴하거나, 이를 승인, 후원, 인증 또는 공식 지원한다는 의미가 아닙니다.

모든 Diagram 및 Workflow Illustration은 Documentation 및 기술 설명을 목적으로 독립적으로 제작되었으며, 각 Application Developer의 공식 자료를 나타내지 않습니다.

**TeamGadget은 모든 Third-party Developer 및 Organization의 지적재산권을 존중합니다.**

---

## Project

**TeamGadget**  
**Universal Real-Time Sync System**
