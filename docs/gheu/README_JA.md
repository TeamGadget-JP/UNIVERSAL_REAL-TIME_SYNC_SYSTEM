# GHEU v1.0.1 — G-HUB Entangle for Unity

**G-HUB Entangle for Unity (GHEU)** は、G-HUBを介してUnityと連携するための独立したTeamGadget同期コンポーネントです。

GHEUはUnityを **TeamGadget Universal Real-Time Sync System** へ接続し、リアルタイムBody同期、Facial / BlendShape同期、Character Slot Routing、Canonical Timeline同期、Smart Swizzle診断、Offline Facial Bake、FBX BridgeによるAnimation転送を提供します。

> GHEUは、日常操作をコンパクトなGHEU Control Windowへ集約し、Character固有設定や診断設定はUnity Inspector側に残す設計です。

---

## 概要

GHEUはTeamGadget同期システムのUnity側Endpointです。

GHEUはCascadeur、Blender、ShapeMixer Entangle、その他Applicationと**直接通信しません**。  
すべてのRoute / Synchronizationは **G-HUB** を介して処理されます。

```text
Cascadeur / GHEC
       │
       ▼
     G-HUB
       │
       ▼
Unity / GHEU
```

GHEUは**Humanoid**と**Generic**の両Character Workflowを公式にサポートします。

- **Humanoid**  
  有効な**Unity Humanoid Avatar**が割り当てられたCharacterで使用します。Unity標準のHumanoid Animation Systemを使用するHumanoid Character向けの基本選択です。

- **Generic**  
  Unity Humanoid Avatarを使用しないCharacterで使用します。Creature、Quadruped、Mechanical Character、その他Custom Rigなどの非Humanoid Bone-driven Characterを含みます。

  Human形状のCharacterでも、Humanoid Avatarを使用せずGeneric設定にしている場合はGeneric Modeを利用できます。

つまりGHEUはHumanoid Characterだけに限定されません。

実際の同期互換性は、Cascadeur / Unity双方に存在するCharacter Hierarchy、Bone Name、Reference Pose、Transform Structureに依存します。

これは、接続Character Structureが互換である非Humanoid Bone-driven Characterにも適用されます。

![GHEU Control Window](images/gheu-control-window.png)

---

## 開発 / 検証環境

GHEU v1.0.1は以下の環境向けに開発・検証されています。

- **Unity 6.3 LTS**
- Windows 64-bit

Validation時に使用した関連TeamGadget環境:

- **G-HUB v1.0**
- **GHEC v1.0.2**
- **Cascadeur 2026.2.2 — Windows 64-bit**

> GHEU v1.0.1の公式対応はUnity 6.3 LTSです。他のUnity Versionは、このReleaseでは公式サポート対象外です。

---

## 配布

GHEU v1.0.1はUnity Packageとして配布されます。

```text
GHEU_v1.0.1_6.3LTS.unitypackage
```

同期Dataを受信するUnity ProjectへImportしてください。

---

# インストール

## 1. Unity PackageをImport

以下をUnity ProjectへImportします。

```text
GHEU_v1.0.1_6.3LTS.unitypackage
```

Import後、GHEU Runtime ScriptはTeamGadget G-HUB Directory配下へ配置されます。

![GHEU Project Structure](images/gheu-project-tree.png)

主要Runtime Component:

- `GHEU_Avatar`
- `GHEU_ShapeKeys`
- `GHEU_System`
- `GHEU_Timeline`

その他のPlayables / Pose関連Runtime Fileも、それぞれのFolderに含まれます。

---

## 2. Scene Componentを作成

GHEUには複数のInternal Runtime / Editor Scriptがありますが、通常ユーザーが直接操作するのは以下の4 Componentだけです。

- `GHEU_System.cs`
- `GHEU_Timeline.cs`
- `GHEU_Avatar.cs`
- `GHEU_ShapeKeys.cs`

その他のGHEU Scriptは内部Support Componentで、通常は手動追加・設定する必要はありません。

### 2.1 GHEU System Objectを作成

1. Unity **Hierarchy**でEmpty GameObjectを作成します。
2. `GHEU_System.cs` をDrag & Dropするか、**Add Component**から追加します。
3. GameObject名は自由に変更できます。

例:

```text
GHEU_System
```

`GHEU_System`はUnity EndpointとG-HUBの接続を管理します。

---

### 2.2 GHEU Timeline Objectを作成

1. Unity **Hierarchy**で別のEmpty GameObjectを作成します。
2. `GHEU_Timeline.cs` をDrag & Dropするか、**Add Component**から追加します。
3. GameObject名は自由に変更できます。

`GHEU_Timeline.cs`をAttachすると、GHEUに必要なUnity `PlayableDirector`機能が自動設定されます。

例:

```text
GHEU_Timeline
```

`GHEU_Timeline`はTimeline関連Bake設定とMulti-Character Facial Bakeを管理します。

---

### 2.3 CharacterへBody同期を追加

Unity **Hierarchy**でImport済みCharacterを選択し、以下をAttachします。

```text
GHEU_Avatar.cs
```

`GHEU_Avatar`はBody同期に必須です。

以下を管理します。

- Character Slot Assignment
- Humanoid / Generic選択
- Root Motion設定
- Root Swizzle
- Interpolation
- Smart Swizzle
- FBX Bridge

---

### 2.4 必要に応じてFacial同期を追加

Facial / BlendShape同期も必要な場合は、同じCharacterへ以下をAttachします。

```text
GHEU_ShapeKeys.cs
```

`GHEU_ShapeKeys`は任意です。

Facial / BlendShape同期またはFacial Bakeを使用する場合のみ必要です。

---

### 代表的なScene構成

```text
SampleScene
├─ Main Camera
├─ Directional Light
├─ Global Volume
├─ GHEU_System
├─ GHEU_Timeline
└─ Character
   ├─ GHEU_Avatar
   └─ GHEU_ShapeKeys   (optional)
```

![GHEU Hierarchy](images/gheu-hierarchy.png)

> 通常のGHEU運用では、ユーザーが直接扱う必要があるのは次の4 Scriptだけです。
>
> - `GHEU_System.cs`
> - `GHEU_Timeline.cs`
> - `GHEU_Avatar.cs`
> - `GHEU_ShapeKeys.cs`
>
> その他のGHEU ScriptはSupport Componentで、通常は手動でAttach / Configureする必要はありません。

---

## 3. GHEU Toolを開く

Unity Editor Menu:

```text
Gadget
└─ G-HUB
   ├─ GHEU Control
   └─ SS Visualizer
```

![GHEU Menu](images/gheu-menu.png)

- **GHEU Control** — Compact Operational Windowを開きます
- **SS Visualizer** — Smart Swizzle Diagnostic Visualizerを開きます

---

# Character Setup要件

Body同期を始める前に、Cascadeur / Unity双方でCharacterを準備します。

## 1. 同じCharacterを使用

**Cascadeur**と**Unity**に同一Characterを用意します。

GHEUはCascadeur側Source CharacterとUnity側Destination Characterの対応Bone Structureを同期します。

---

## 2. Reference Poseを一致させる

初回同期前に、両Characterを同じReference Poseへ合わせます。

推奨:

- **T-pose**
- **A-pose**

両側で同じPoseを使用してください。

例として、CascadeurをT-pose、UnityをA-poseのままにしないでください。

Reference PoseはSmart Swizzle / Reference Pose Initializationで使用されるため重要です。

---

## 3. Bone Hierarchy / Bone Nameを一致させる

Cascadeur / Unity Characterでは、対応する以下の情報が一致している必要があります。

- Bone Hierarchy
- Bone Structure
- Bone Name

GHEUはユーザーによるManual Bone Mappingを不要にする設計ですが、両側のCharacter Structureに互換性が必要です。

同じBoneは、CascadeurとUnityの両方で同じ部位を表す必要があります。

---

## 4. GHEUはHumanoid Character限定ではない

GHEUはUnity Humanoid Rigだけに限定されません。

GHEU v1.0.1公式対応:

- **Humanoid**
- **Generic**

これにより、非Humanoid Bone-driven Characterも同期できます。

例:

- Quadruped
- Creature
- Mechanical Character
- その他Custom Bone-driven Rig

ただし、**あらゆるRigが必ず正しく同期することを保証するものではありません**。

成功可否は以下を含む要素に依存します。

- Matching Bone Hierarchy
- Matching Bone Name
- Compatible Reference Pose
- Compatible Transform Structure
- 双方Applicationで利用可能なCharacter Data

期待通り同期しない場合は、**SS Visualizer**でSmart Swizzle / Reference Pose Pipelineを確認してください。

# クイックスタート — Body同期

1. **G-HUB**を起動します。
2. **Cascadeur**を起動し、**G-HUB Entangle for Cascadeur (GHEC)** を接続します。
3. GHEUを含むUnity Projectを開きます。
4. Scene上の`GHEU_System`を追加または選択します。
5. Characterへ`GHEU_Avatar`を追加します。
6. 必要な**Character Slot**を割り当てます。
7. 正しい**Rig Type** (`Humanoid` / `Generic`) を選択します。
8. **Body Sync Enabled**を有効化します。
9. **Gadget > G-HUB > GHEU Control**を開きます。
10. **CONNECT G-HUB**を押します。
11. 対応Character RouteがActiveになることを確認します。
12. 必要に応じて**TIMELINE SYNC**を有効化します。

![GHEU Connected](images/gheu-connected.png)

---

# GHEU Control Window

GHEU Control Windowは、日常運用向けに設計されています。

Unity Editorの狭い領域にもDockできるよう、意図的にCompactなLayoutです。

## HUB

HUB SectionにはActive G-HUB Sessionが表示されます。

Offline時:

- `SESSION OFFLINE`
- `CONNECT G-HUB`
- `TIMELINE SYNC OFF`

Connected時:

- `SESSION ACTIVE`
- `DISCONNECT G-HUB`
- `TIMELINE SYNC ON`

Windowにはさらに以下が表示されます。

- Host
- Control Port
- **Select System**

`Select System`はControl Windowが使用する`GHEU_System` Instanceを選択します。

---

## CHARACTERS

GHEUは最大 **5 Character Slots** をサポートします。

- C1
- C2
- C3
- C4
- C5

各Rowには以下が表示されます。

- **Slot**
- **Avatar**
- **Body**
- **Face**
- **Actions**

Action例:

- **Select** — 割り当てCharacterをUnity上で選択
- **FBX** — 利用可能な場合、FBX Bridge Workflowを開始

Body / Face Stateは、対応G-HUB RouteがActiveかどうかを示します。

---

## TIMELINE / FACIAL BAKE

下部Sectionには共通Timeline / Facial Bake Controlがあります。

- Bake Range
- FPS
- Select Timeline
- Output Folder
- Facial Bake

`FACIAL BAKE - ALL ACTIVE SLOTS`は、有効なActive Facial Routeが存在する場合のみ使用できます。

---

# GHEU_System

`GHEU_System`にはUnity Endpoint Connection設定があります。

![GHEU System Inspector](images/gheu-system-inspector.png)

## G-HUB Control

### Connect To Hub

このSystemでG-HUB Connection Workflowを有効化します。

### Hub Host

Default:

```text
127.0.0.1
```

通常のGHEU Workflowは、同一Windows PC上でのLocal通信を想定しています。

### Hub Port

Default:

```text
8000
```

GHEU Hub PortはG-HUB Control Portと一致させてください。

---

## Timeline

### Timeline Sync

G-HUB Canonical Timeline同期への参加を有効化します。

この設定はGHEU Control Windowからも操作できます。

---

# GHEU_Avatar

`GHEU_Avatar`はUnity CharacterへAttachする主要Body同期Componentです。

![GHEU Avatar Inspector](images/gheu-avatar-inspector.png)

---

## G-HUB Routing

### Character Slot

Characterを次のG-HUB Character Slotのいずれかへ割り当てます。

- Character 1
- Character 2
- Character 3
- Character 4
- Character 5

対応するCascadeur Characterも同じCharacter Slotを使用する必要があります。

GHEU v1.0.1は現在のURSS Explicit Character Routing Contractに従います。

| GHEU Character Slot | URSS Route |
| --- | --- |
| Character 1 | `char_01` |
| Character 2 | `char_02` |
| Character 3 | `char_03` |
| Character 4 | `char_04` |
| Character 5 | `char_05` |

Character Identityは割り当てられたURSS Route / Slotから決まります。Bone Requestは元のJoint名を使用し、`character1:`、`character2:`等のLegacy Prefixは不要です。

### Body Sync Enabled

このCharacterのBody同期を有効 / 無効化します。

### Rig Type

対応値:

- **Humanoid**
- **Generic**

どちらもGHEU v1.0.1で公式サポートされます。

### Local Position Scale

`Local Position Scale`は、GHEUがRoot MotionおよびTranslation対応Boneに使用する位置変換倍率をInspectorへ公開します。

Default:

```text
0.01
```

Default値は、従来GHEUで使用していたCentimeter → Meter変換を維持します。

例:

- `0.01` — 標準Default挙動
- `0.005` — Defaultの半分のTranslation量
- `0.02` — Defaultの2倍のTranslation量

同じ値がLive Body同期とOffline Body Animation処理の両方に使用されるため、Live MotionとBaked Outputの位置Scaleは一致します。

Rotationには適用されません。

> Destination Character側で異なる位置変換が必要な場合を除き、`Local Position Scale`は`0.01`のまま使用してください。

---

# Root Motion Settings

Root Motion同期は任意です。

## Sync Root Motion

Root Bone Translation / Rotation同期を有効化します。

無効時、GHEUは設定Root Motion Pathを適用せず、Mapped Body Poseのみ同期します。

## Root Bone Name

Root Motion同期時に使用するCharacter Root Boneを指定します。

## Root Rotation Offset

Unity Character Root OrientationとSource Coordinate Systemが直接一致しない場合にRotation Offsetを適用します。

Model Import OrientationとCascadeur Root Orientationが一致しない場合に利用できます。

---

# Root Swizzle (Advanced)

Root SwizzleはRoot Translation / Rotation AxisをRemapします。

利用可能Control:

- Root Pos X
- Root Pos Y
- Root Pos Z
- Root Rot X
- Root Rot Y
- Root Rot Z

Imported Coordinate System / Root Hierarchyにより、Characterごとに異なるMappingが必要な場合があります。

> Root SwizzleはAdvanced Adjustmentです。Root Translation / Rotationが誤動作する場合を除き、変更しないでください。

---

# Interpolation

受信Body MotionはInterpolationでSmooth化できます。

## Use Interpolation

Body Interpolationを有効化します。

## Lerp Speed

General Body Interpolation Speedを制御します。

## Foot Lerp Speed

Foot Interpolationを独立制御します。

これによりFoot ResponseだけをBody全体とは別に調整できます。

---

# Reference Pose / Smart Swizzle

GHEUはRig-Agnostic Body同期向けにCached Reference Pose Workflowを使用します。

Character Routeが初めてActiveになった際、GHEUは現在のUnity Reference PoseをCaptureし、対応Cascadeur Reference Pose DataをRequestします。

生成されたCacheは、互換性のある後続Connectionで再利用できます。

## Cache Status

例:

```text
Missing
Ready (65 bones)
Ready (100 bones)
```

`Ready`はMapped Character向けReference Cacheが利用可能であることを示します。

## Smart Swizzle

必要に応じてSmart Swizzle Reference Processを開始・更新します。

## Reset Pose

Cached Reference Poseへ戻します。

> Body RouteがActiveな間は、次のLive Body PacketによってReset Pose結果が上書きされる場合があります。主にBody Sync停止中 / Disconnect中に使用してください。

## SS Visualizer

選択Character向けSmart Swizzle Diagnostic Visualizerを開きます。

---

# Smart Swizzle Visualizer

**SS Visualizer**はReference Pose / Mapping Pipelineを確認する診断Toolです。

![Smart Swizzle Visualizer](images/gheu-ss-visualizer.png)

主な用途:

- 正しく同期しないRigの診断
- Reference Pose Pipeline完了確認
- BoneごとのMapping確認
- Orientation / Axis差の確認
- Rest / Live / Target Data欠落の特定

Characterが正常動作している場合、通常同期にSS Visualizerは不要です。

---

## Reference / Live Status

Status Sectionには以下があります。

### Character Route

選択Character RouteがActiveか表示します。

### Reference Cache

現在のCached Reference Pose Stateを表示します。

### Mapped Bones

現在MappedされているBone数です。

### Cascadeur Rest

Mapped Boneのうち、Cascadeur Reference Pose Dataを受信した数です。

### Live Samples Seen

Live Body Sampleを受信したMapped Bone数です。

### Resolved Targets Seen

解決済みUnity Target Bone数です。

### Diagnostic Issues

検出されたSmart Swizzle Diagnostic Issue数を表示します。

Complete Pipelineが利用可能になると、VisualizerはすべてのMapped BoneでDiagnostic Pipeline完了を表示します。

---

## Bone Browser

Bone Browserには以下があります。

- Search
- Filter
- Bone Selection
- Cascadeur Request Name
- Diagnostic State
- Select Bone
- Frame Bone
- Copy Selected Diagnostic

問題Boneを個別に調査できます。

---

## Scene View Visualization

VisualizerはUnity Scene ViewへDiagnostic Marker / Axisを直接表示できます。

Option:

- All Bone Status Markers
- All Bone Resolved Target Axes

選択Boneについては以下を表示できます。

- Unity Rest
- Cascadeur Rest (mapped)
- Cascadeur Live (mapped)
- Resolved Unity Target
- Actual Applied Pose

Axis SizeでScene View表示Scaleを調整します。

---

## Status Marker Legend

Marker Colorは以下のStateを示します。

- Ready
- No Live
- Route Inactive
- Missing Rest
- No Target

これらのMarkerを使うと、Synchronization Pipelineの未完了箇所を素早く特定できます。

---

## Selected Bone Pipeline

選択Boneでは以下を表示できます。

- Unity Rest
- Cascadeur Rest
- Cascadeur Live
- Motion Delta / Mapping Mode
- Resolved Target
- Actual Local
- Target vs Actual

より深い診断向けにTranslation / Orientation値も数値表示されます。

---

# Rig-Agnostic同期

GHEUは、互換Character Structureに対してユーザーがManual Bone Mappingを作成しなくてもよいよう設計されています。

Character Structure / Reference Pose情報はG-HUB Connection Workflow経由で交換され、GHEUがUnity側Target Mappingを内部解決します。

同じArchitectureを両Rig Typeで使用します。

- Humanoid
- Generic

これにより、一般的なHumanoidだけでなく、非Humanoid Bone-driven Characterもサポートできます。

実際の互換性は、接続Application双方に存在するHierarchy / Transform Dataに依存します。

---

# Humanoid Workflow

Humanoidは公式対応です。

推奨手順:

1. `Rig Type`を**Humanoid**に設定します。
2. Unity Modelに有効なHumanoid Avatarがあることを確認します。
3. Body Syncを有効化します。
4. 必要な場合のみRoot Motionを設定します。
5. 対応GHEC Character Slotを接続します。
6. 結果が不正な場合はSmart Swizzle診断を使用します。
7. Offline Body Animation転送にはFBX Bridgeを使用します。

GHEUは生成Humanoid Animation Asset準備時にUnity ModelImporter Workflowを使用します。

---

# Generic Workflow

Genericは公式対応です。

推奨手順:

1. `Rig Type`を**Generic**に設定します。
2. Body Syncを有効化します。
3. Characterが必要とする場合のみRoot Motion / Root Swizzleを設定します。
4. 対応GHEC Character Slotを接続します。
5. Orientation / Reference Pose問題の診断にはSS Visualizerを使用します。
6. Offline Body Animation転送にはFBX Bridgeを使用します。

Generic SupportはHumanoid形状のCharacterに限定されません。

Source CharacterとStructureに互換性があれば、非Humanoid Rigも同期できます。

---

# FBX Bridge

FBX BridgeはBody Animationを標準FBX Source Assetとして作成し、Unity ModelImporterからHumanoid / Generic AvatarとEmbedded AnimationClipを生成できるようにします。

`GHEU_Avatar`の主なControl:

- Body Asset Rig
- Output Folder
- Use Slot Default
- Asset Name
- FBX Bridge
- Status

---

## Body Asset Rig

選択Body Asset Rig Modeを表示します。

- Humanoid
- Generic

Active GHEU Character Workflowに従います。

## Output Folder

生成Body Animation Assetの保存先を指定します。

`...` ButtonからUnity Project Folderを選択します。

## Use Slot Default

現在Character Slotに対応するDefault Output Folderへ戻します。

## Asset Name

生成Animation Asset名を設定します。

## FBX Bridge

Animation Transfer / Import Workflowを開始します。

Export前にCharacter RouteがActiveである必要があります。

## Status

FBX Bridge Stateと最後に完了したExport情報を表示します。

> Animation Clip Loop / Root Transform PolicyはImport後もUnity側設定です。

---

# GHEU_ShapeKeys

`GHEU_ShapeKeys`はFacial / BlendShape同期を有効化します。

![GHEU ShapeKeys Inspector](images/gheu-shapekeys-inspector.png)

---

## G-HUB Shape Key Route

### Character Slot

Facial同期をG-HUB Character Slotへ割り当てます。

Facial Character Slotは対象Characterに対応させてください。

### Shape Sync Enabled

Facial / BlendShape同期を有効 / 無効化します。

### Target Root

Character Facial / BlendShape Routeが使用するTarget Object Hierarchyを指定します。

---

## Diagnostics

### Cached Shape Count

Target Character向けにGHEUが現在CacheしているShape Key数を表示します。

---

# Timeline Setup

GHEUは`GHEU_Timeline` Scene ObjectとUnity `PlayableDirector`を組み合わせて使用します。

Timeline例:

![GHEU Timeline](images/gheu-timeline.png)

代表的なTimeline TrackにはBody FBX Bridgeで生成したAnimation Clipを配置できます。

---

# GHEU_Timeline

`GHEU_Timeline`にはBake設定とMulti-Character Facial Bake Controlがあります。

![GHEU Timeline Inspector](images/gheu-timeline-inspector.png)

---

## Bake Settings

### Bake Start Frame

Facial Bakeに含める最初のFrameです。

### Bake End Frame

Facial Bakeに含める最後のFrameです。

### Bake Fps

生成Facial `AnimationClip`で使用するDestination / Output Frame Rateです。

SE Source Timelineは異なるFrame Rateでも構いません。GHEU Offline Facial Bakeは、Source / DestinationのFrame番号一致を前提にせず、Canonical Timeで同期します。

例:

```text
Unity Bake Output: 24 FPS
SE Timeline:       60 FPS

Unity 24F = 1.0 second
SE    60F = 1.0 second
```

### Bake Interval

Bake ProcessのSampling Intervalです。

---

# Facial Multi-Character Bake

## Facial Bake Output Folder

生成Facial Animation Clipの保存先Folderです。

`...` ButtonでOutput Folderを選択します。

## Facial Clip Name Prefix

生成Facial Animation Clip名に使うPrefixです。

## FACIAL BAKE - ALL ACTIVE SLOTS

Active Facial Character SlotすべてのFacial Bakeを開始します。

動作Rule:

- ActiveなFacial Character SlotのみBake
- C1 → C5の順でSequential処理
- 各Characterへ独立した**BlendShape-only AnimationClip**を生成
- Incoming Bake Streamに存在するShape Keyのみ収録
- Body Animationは別途**FBX Bridge**で処理
- Source / Output FPSが異なってもCanonical Timeを保持

この分離により、Body / Facial Animation Assetを独立して管理できます。

---

# Canonical Timeline同期

GHEUはG-HUB Canonical Timeline Systemへ参加できます。

同期対象には以下を含められます。

- Current Frame
- Play
- Pause
- Stop
- Scrub / Seek
- Timeline Range
- Frame Rate

Timeline Syncは以下から操作できます。

- `GHEU_System`
- GHEU Control Window

---

# Animatorとの競合

Unity `Animator`とGHEUが同じCharacter Transformを書き換える場合があります。

Live同期中にCharacterが震える、Incoming Poseと競合する、安定しない場合は、Animatorが同じBoneを制御していないか確認してください。

Live同期では、Workflowに応じて競合するAnimation Ownershipを解除または無効化してください。

---

# Character Structure要件

GHEUのRig-Agnostic Workflowは通常のManual Bone Mappingを不要にしますが、Source / Destination Character Structureには互換性が必要です。

直接対応が期待される箇所では、Hierarchy / Bone Nameの一致が重要です。

GHEUは16-bit Bone IDを使用します。

現行GHEU v1.0.1 Transportは、Single-datagram UDP Payload Limitにより、同期Characterあたり最大**2,112 Bone Entry**まで対応します。

内部Bone ID / Bone Count Field自体は16-bitですが、v1.0.1ではPacket Splittingを実装していません。

---

# トラブルシューティング

## GHEUがG-HUBへ接続できない

以下を確認してください。

- G-HUBが起動している
- `Hub Host`が正しい
- GHEU / G-HUBが同じControl Portを使用している
- 対象`GHEU_System`が選択されている
- Windows Firewall / Security SoftwareがLocal通信をBlockしていない

---

## Body RouteがOFFのまま

以下を確認してください。

- `GHEU_Avatar`が対象CharacterへAttachされている
- 正しいCharacter Slotが選択されている
- **Body Sync Enabled**が有効
- GHECが接続済み
- 対応Cascadeur Character Slotが選択されている
- G-HUB上にRouteが存在する

---

## Face RouteがOFFのまま

以下を確認してください。

- `GHEU_ShapeKeys`がAttachされている
- 正しいCharacter Slotが選択されている
- **Shape Sync Enabled**が有効
- Target Rootが正しい
- Facial SourceがActive
- 対応G-HUB Routeが存在する

---

## 同期中にCharacterが震える

以下を確認してください。

- Animatorが同じTransformを書いていないか
- 別Animation SystemがCharacterを制御していないか
- Interpolation設定が適切か

---

## Smart Swizzle CacheがMissing

Unity Characterを意図したReference Poseにした状態でCharacter Routeを確立します。

それでもReadyにならない場合:

1. **SS Visualizer**を開く
2. Character Routeを確認
3. Cascadeur Rest Coverageを確認
4. Live Samples Seenを確認
5. Resolved Targets Seenを確認
6. Diagnostic Issuesを確認

---

## Generic CharacterのOrientationが正しくない

以下を確認してください。

- Root Rotation Offset
- Root Swizzle
- Root Hierarchy
- SS VisualizerのBoneごとのDiagnostic

---

## FBX Bridgeを実行できない

以下を確認してください。

- G-HUBが接続済み
- Character RouteがActive
- Output Folderが有効
- Rig TypeがCharacterと一致
- Asset Nameが有効

---

## Facial Bake Buttonが無効

以下を確認してください。

- G-HUBが接続済み
- 少なくとも1つのFacial RouteがActive
- 対象Characterの`GHEU_ShapeKeys`が有効
- 対象Timelineが選択済み

---

# Open Source

Unity側GHEU Source CodeはOpen Sourceとして公開されています。

適用LicenseはGHEU Releaseに同梱されています。

---

# Third-Party Notice

GHEUはUnityとの連携を目的とした独立した**TeamGadget** Projectです。

TeamGadgetはUnity TechnologiesまたはUnityのDeveloper / Ownerと提携、承認、スポンサー、認証、公式サポート関係を持ちません。

Unityおよび関連製品名 / Trademarkは各権利者に帰属します。

GHEUはTeamGadget G-HUB Architectureを通じてのみ他のThird-party Applicationと相互運用します。Third-party製品への参照は、互換性 / Interoperabilityの識別目的のみです。

---

# Project

**TeamGadget**  
**GHEU — G-HUB Entangle for Unity v1.0.1**
