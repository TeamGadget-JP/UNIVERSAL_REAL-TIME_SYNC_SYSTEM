>## ダウンロード
>
>[GitHub Releases](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases)
>
>## スタンドアロンアプリケーション（解凍が必要）
>*   **[G-HUB v1.0.0](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases/download/g-hub-v1.0.0/G-HUB_v1.0_Windows_x64.zip)**  
>    Universal Real-Time Sync Systemの動作に必要です。  
>    **インストール方法:** ファイルを解凍してください。スタンドアロンアプリケーションです。
>*   **[ShapeMixerEntangle v1.0.0](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases/download/se-v1.0.0/ShapeMixer_Entangle_v1.0_Windows_x64.zip)**  
>    Facial / Shape Keyオーサリング用Endpointです。  
>    **インストール方法:** ファイルを解凍してください。スタンドアロンアプリケーションです。
>
>## Blender（⚠️ 解凍しないでください）
>*   **[GHEB v1.0.1](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases/download/gheb-v1.0.1/GHEB_v1_0_1_Blender5_2LTS.zip)**  
>    Blender 5.2 LTS用Endpointです。  
>    **インストール方法:** ⚠️ **解凍しないでください。** `.zip` ファイルをダウンロードし、BlenderのAdd-on / Extension設定からそのままインストールしてください。
>
>## ゲームエンジン / DCCツール（解凍が必要）
>*   **[GHEC v1.0.2](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases/download/ghec-v1.0.2/GHEC_v1.0.2_Windows_x64.zip)**  
>    Cascadeur 2026.2用Endpointです。  
>    **インストール方法:** ファイルを解凍し、指定されたプラグインディレクトリへ手動で配置してください。
>*   **[GHEU v1.0.1](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases/download/gheu-v1.0.1/GHEU_v1.0.1_6.3LTS.unitypackage)**  
>    Unity 6.3 LTS用Endpointです。  
>    **インストール方法:** 圧縮されている場合は解凍し、通常の `.unitypackage` インポート手順で導入してください。
>*   **[GHEG v1.0.0](https://github.com/TeamGadget-JP/UNIVERSAL_REAL-TIME_SYNC_SYSTEM/releases/download/gheg-v1.0.0/GHEG_v1.0.0_Godot4.7.NET_RELEASE.zip)**  
>    Godot 4.7 .NET用Endpointです。  
>    **インストール方法:** ファイルを解凍し、指定されたプラグインディレクトリへ手動で配置してください。

### コミュニティによる拡張
URSSのGHEBをフォークし、BlenderのAuto-Rig Pro（ARP）対応版を開発している方のリポジトリは[こちらへ](https://github.com/seonghyeone/Blender---cascaduer-)。

![TeamGadget Unity Workflow](docs/images/urss-top.png)

現在のURSSスイートでは、以下の機能を提供しています。

- リアルタイムBody同期
- リアルタイムFacial / Shape Key同期
- 最大 **5 Character Slots**
- 一元化されたRoute管理
- Canonical Timeline同期
- 対応Body Endpoint向けのRig-Agnostic / Smart Swizzleワークフロー
- Unity / Blender / Godot向けOffline Facial Animation Bake
- Blender Actionへ直接出力するOffline Body Animation Bake
- Unity / Godot向けFBX Bridge Body Animation転送ワークフロー
- ShapeMixer Entangleによる専用Facial Animationオーサリング環境

---

## Unity Workflow

現在のUnity Endpoint: **GHEU v1.0.1**

Unityワークフローは以下を組み合わせて使用します。

- Body Animation: **Cascadeur + GHEC**
- Facial / BlendShape Animation: **ShapeMixer Entangle**
- RoutingおよびCanonical同期: **G-HUB**
- Unity Endpoint: **GHEU**

![TeamGadget Unity Workflow](docs/images/unity_workflow.png)

Unityでのプロダクションワークフロー:

![TeamGadget Unity Workflow](docs/images/GHEU-workflow.png)

リアルタイムBody / Facial同期も、同じG-HUB Sessionを通して実行できます。

Offline Facial Bakeでは、SourceとDestinationのFrame Rateを一致させる必要はありません。GHEUはCanonical Timeを維持し、各Output Frameを対応するSE Source Timeに対して解決します。

---

## Blender Workflow

現在のBlender Endpoint: **GHEB v1.0.1**

Blenderワークフローは以下を組み合わせて使用します。

- Body Animation: **Cascadeur + GHEC**
- Facial / Shape Key Animation: **ShapeMixer Entangle**
- RoutingおよびCanonical同期: **G-HUB**
- Blender Endpoint: **GHEB**

![TeamGadget Blender Workflow](docs/images/blender_workflow.png)

Blenderでのプロダクションワークフロー:

![TeamGadget Unity Workflow](docs/images/GHEB-workflow.png)

リアルタイムBody / Facial同期は、同一のGHEB Endpointを通して実行できます。

Offline Bakeでは、SourceとDestinationのFrame Rateを一致させる必要はありません。GHEBはCanonical Timeを維持し、各Blender Output Frameを対応するRoute Source Timeに対して解決します。

---

## Godot Workflow

現在のGodot Endpoint: **GHEG v1.0.0**

Godotワークフローは以下を組み合わせて使用します。

- Body Animation: **Cascadeur + GHEC**
- Facial / Blend Shape Animation: **ShapeMixer Entangle**
- RoutingおよびCanonical同期: **G-HUB**
- Godot .NET Endpoint: **GHEG**

![TeamGadget Godot Workflow](docs/images/godot_workflow.png)

Godotでのプロダクションワークフロー:

![TeamGadget Unity Workflow](docs/images/GHEG-workflow.png)

GHEGは、リアルタイムBody / Facial同期、5つのCharacter Slot、Canonical Timeline同期、Smart Swizzle診断、FBX Bridge Import、Offline Facial Animation Bakeをサポートしています。

EndpointはBody / Facial Animation AssetをGodot Project内へ届けます。最終的にそれらのAssetをProduction Character Sceneへ適用する作業は、通常のGodotオーサリング工程としてユーザー側で行います。

---

## Components

| Component | Current Version | Role | Distribution |
| --- | --- | --- | --- |
| **G-HUB** | v1.0 | 中央通信、Routing、Character Slots、Canonical Timeline | Windows x64向けビルド済みアプリケーション |
| **GHEC** | v1.0.2 | Cascadeur Endpoint | 混在配布: Source Files + 保護されたCompiled Backend |
| **GHEU** | v1.0.1 | Unity Endpoint | Open Source + Unity Package |
| **ShapeMixer Entangle (SE)** | v1.0 | Facial / Shape Keyオーサリングおよび同期 | Windows x64向けビルド済みアプリケーション |
| **GHEB** | v1.0.1 | Blender Endpoint | Open-source Blender Add-on |
| **GHEG** | v1.0.0 | Godot .NET Endpoint | Source配布型TeamGadget Endpoint |

---

## Current Components

### G-HUB v1.0

**Universal Real-Time Sync Hub**

G-HUBはシステムの中心となるコンポーネントです。

以下を管理します。

- Endpoint登録
- Character Slot Routing
- Body / Facial Channel
- Route作成 / 削除
- Canonical TimelineのOwnershipおよび配信
- 設定可能なLocal Network
- Runtime Channel / Route監視

Documentation:

[`docs/g-hub/README_JA.md`](docs/g-hub/README_JA.md)

---

### GHEC v1.0.2

**G-HUB Entangle for Cascadeur**

GHECはCascadeurをG-HUBへ接続し、以下を提供します。

- リアルタイムCharacter Streaming
- 最大5 Character Slots
- `char_01` ～ `char_05` への明示的Character Assignment
- Sceneに保持されるCharacter Slot Assignment
- Smart Swizzle / Reference Pose Exchange
- Canonical Timeline同期
- 対応Destination Endpointで使用されるBridge Workflow
- 旧Workflow向けLegacy Prefix互換

GHECの使用には、対応する有料Cascadeur Licenseが必要です。

Release Package:

```text
GHEC_v1.0.2_Windows_x64.zip
```

Documentation:

[`docs/ghec/README_JA.md`](docs/ghec/README_JA.md)

---

### GHEU v1.0.1

**G-HUB Entangle for Unity**

GHEUはUnityをG-HUBへ接続し、以下を提供します。

- リアルタイムBody同期
- Humanoid / Generic Workflow
- Rig-Agnostic同期
- Smart Swizzle診断
- 設定可能なLocal Position Scale
- Root Motion / Interpolation Control
- リアルタイムFacial / BlendShape同期
- Multi-Character Routing
- Canonical Timeline同期
- GHEU Offline Facial Bake
- FBX Bridge Body Animation転送

対応Unity Version:

- **Unity 6.3 LTS**
- Windows 64-bit
- Release Package: `GHEU_v1.0.1_6.3LTS.unitypackage`

GHEUはUnity 6.3 LTS向けに開発・検証されています。その他のUnity Versionは、このReleaseでは公式サポート対象外です。

Documentation:

[`docs/gheu/README_JA.md`](docs/gheu/README_JA.md)

---

### GHEB v1.0.1

**G-HUB Entangle for Blender**

GHEBはBlenderをG-HUBへ接続し、以下を提供します。

- リアルタイムBody同期
- リアルタイムFacial / Shape Key同期
- 最大5 Character Slots
- Body + Facial同時同期
- Rig-Agnostic / Smart Swizzle Body Workflow
- Floating Smart Swizzle Diagnostics
- Optional Body Interpolation
- 設定可能なTranslation Scale
- Canonical Timeline同期
- Blender Armature ActionへのOffline Body Bake
- Multi-Mesh Facial同期 / Bake
- Multi-Character Facial Bake

対応Blender Version:

- **Blender 5.2 LTS**
- Windows 64-bit
- Release Package: `GHEB_v1_0_1_Blender5_2LTS.zip`

GHEBはBlender 5.2 LTS向けに開発・検証されています。その他のBlender Versionは、このReleaseでは公式サポート対象外です。

Documentation:

[`docs/gheb/README_JA.md`](docs/gheb/README_JA.md)

---

### GHEG v1.0.0

**G-HUB Entangle for Godot**

GHEGはGodot .NETをG-HUBへ接続し、以下を提供します。

- リアルタイムBody同期
- リアルタイムFacial / Blend Shape同期
- 最大5 Character Slots
- `AUTO ASSIGN` / `ASSIGN ALL` による安全なSetup Assistance
- Rig-Agnostic / Smart Swizzle Body Workflow
- SS Visualizer診断
- Canonical Timeline同期
- URSS Timeline Transport専用GHEG Transport Node
- FBX Bridge Body Animation転送およびGodot Import
- Godot Animation ResourceへのOffline Facial Bake
- 設定可能なLocal Position Scale

検証済み環境:

- **Godot 4.7.2 .NET**
- Windows 64-bit
- Release Package: `GHEG_v1.0.0_Godot4.7.NET_RELEASE.zip`

GHEGのSetupには、Godot側で複数のNodeとReference設定が必要です。専用GHEG Documentationには、C1の完全なStep-by-Step Setup Guide、新規Projectにおける.NET初期化、Node Structure、Troubleshootingが含まれています。

Documentation:

[`docs/gheg/README_JA.md`](docs/gheg/README_JA.md)

---

### ShapeMixer Entangle v1.0

**Facial / Shape Key Authoring Endpoint**

ShapeMixer EntangleはFacial Animation専用ツールで、以下を提供します。

- FBX / glTF Shape Key Import
- Layered XY Pads
- Additional Shape Key Controls
- Presets
- Multi-Take Animation
- Bezier Curve Editing
- Audio Waveform Reference
- 最大5 Character Slots
- リアルタイムG-HUB Facial同期
- Canonical Timeline同期
- 対応Endpoint向けOffline Facial Bake Workflow

Documentation:

[`docs/se/README_JA.md`](docs/se/README_JA.md)

---

## Character Slots

システムは最大 **5 Character Slots** をサポートします。

```text
C1 → char_01
C2 → char_02
C3 → char_03
C4 → char_04
C5 → char_05
```

Character Slotによって、複数Characterを使用している場合でも、Body、Facial、Bake、Timeline関連データを分離して扱えます。

現在のRouting Contractでは、**URSS Route / Character SlotそのものをCharacter Identityとして扱います**。Bone / Joint名は、そのRoute内のCharacterに対するローカル名として扱われます。

GHEC v1.0.2では、このContractに合わせて明示的なCascadeur Character Assignmentを導入しつつ、旧Project向けにLegacy Prefix互換も維持しています。

---

## Canonical Timeline Synchronization

G-HUBは、現在のProduction Endpoint間で **完全な双方向Timeline同期** を提供します。

- **Cascadeur / GHEC**
- **Unity / GHEU**
- **Blender / GHEB**
- **Godot / GHEG**
- **ShapeMixer Entangle / SE**

参加している任意のEndpointがTimelineを操作でき、接続された他のEndpointはG-HUBを通じて同じCanonical Playback Stateへ追従します。

同期されるStateには以下が含まれます。

- Current Time / Frame Position
- Play
- Pause
- Stop
- Scrub / Seek
- Playback Range
- Frame Rate

### FPSが異なっていてもTimeはCanonicalに維持されます

同期モデルが維持するのは、単なる同一Frame番号ではなく **Time** です。

言い換えると:

> **すべてのEndpointで、1秒は常に1秒です。**

接続されたApplicationのFrame Rateが異なる場合、それぞれのEndpointは共有されたCanonical Timeを自身のLocal Frame Positionへ変換します。

例:

```text
30 FPS endpoint → Frame 30 = 1.0 second
60 FPS endpoint → Frame 60 = 1.0 second
```

そのため、表示上のFrame番号が異なっていても、Animation Timeは同期されたままになります。

これにより、Cascadeur、Unity、Blender、Godot、ShapeMixer Entangleは、それぞれ異なるLocal FPS設定を使用していても同期を維持できます。

Timeline同期は双方向です。Play、Pause、Stop、Scrub / Seek、Range変更、Timeline PositionはG-HUBを通じて伝播し、参加Endpoint間の同期を維持します。

---

## Design Principles

このSuiteは、いくつかの基本方針に基づいて設計されています。

### Centralized Routing

各EndpointはApplication同士でPoint-to-Point通信を実装するのではなく、G-HUBを通して通信します。

### One Active Destination Route

URSSは **Cascadeur + ShapeMixer Entangle ↔ 1つのDestination Endpoint** を基本設計としています。

Unity、Blender、Godotなど複数のDestination Endpointへ同時Streamingすることは前提としていません。これにより、Route Ownershipと同期挙動を明確かつ決定的に保ちます。

### Character-Slot Isolation

各CharacterをLogical Slotへ割り当てることで、複数CharacterがActiveな場合でもBody / Facial Dataを分離して扱います。

### Rig-Agnostic Body Synchronization

対応Body Endpoint間でStructureとReference Pose情報を交換し、互換性のあるRigに対して毎回ユーザーが手動Bone Mappingを作成する必要がない設計を採用しています。

### Smart Swizzle

Smart Swizzleは各Application固有のRig Conventionを維持したまま、接続されたCharacter Structure間のReference PoseおよびLocal Axisの差異を解決します。

### Single-Target Offline Bake

Offline Bakeは意図的に1 Targetずつ実行します。Bake Ownershipを明確にし、Batch処理の複雑さよりも信頼性を優先しています。

### Separate Body and Facial Production Paths

必要に応じて、Body / Facial Animationはすべてを1つのExport方式へ押し込まず、それぞれ専用のProduction Workflowを使用します。

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

各ComponentのSourceおよびRelease Assetは、それぞれのDistribution Modelに応じて整理されています。

---

## Licensing

各Componentには、それぞれ独自のLicense / Distribution Termsがあります。

各Componentに含まれる `LICENSE`、`LICENSE.txt`、または `EULA.md` を確認してください。

概要:

- **G-HUB** — TeamGadget独自バイナリ配布
- **ShapeMixer Entangle** — TeamGadget独自バイナリ配布
- **GHEC** — Mixed Distribution。Source FilesとCompiled Proprietary Backendにはそれぞれ別のLicense条件が適用されます
- **GHEU** — Open-source Unity Endpoint
- **GHEB** — Open-source Blender Endpoint
- **GHEG** — 独自License条件のもとSource配布されるTeamGadget Godot Endpoint

Third-party LibraryおよびRuntimeには、それぞれのLicense / Noticeが適用されます。

---

## Third-Party Notice

このRepositoryには、Third-party ApplicationおよびFile Formatとの相互運用を目的として開発された、独立した **TeamGadget** Projectが含まれています。

明示的な記載がない限り、TeamGadgetはCascadeur、Unity、Blender、Godot、その他参照されるThird-party Productの開発者または権利者と、提携、承認、スポンサー、認証、公式サポート関係にはありません。

すべてのThird-party Product名およびTrademarkは、それぞれの権利者に帰属します。

---

## Logo and Trademark Notice

このREADME内のArchitecture DiagramおよびWorkflow Illustrationには、**Cascadeur、Unity、Blender、Godot** などThird-party ApplicationのLogoおよびVisual Identifierが含まれています。

これらのLogoは、**Universal Real-Time Sync System (URSS)** が対応するApplicationを識別・説明する目的でのみ使用されています。

すべてのThird-party Logo、Product Name、Trademarkは、それぞれの権利者に帰属します。

これらのLogoを掲載していることは、各Trademark OwnerがTeamGadgetまたはURSSと提携していること、あるいは承認、スポンサー、認証、公式サポートを行っていることを意味しません。

すべてのDiagramおよびWorkflow IllustrationはDocumentation / Technical Explanationを目的として独自に作成されたものであり、各Application Developerの公式資料ではありません。

**TeamGadgetは、すべてのThird-party DeveloperおよびOrganizationの知的財産権を尊重します。**

---

## Project

**TeamGadget**  
**Universal Real-Time Sync System**
