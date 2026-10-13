# ShapeMixer Entangle v1.0

**Facial / Shape Key Authoring Endpoint**

**ShapeMixer Entangle (SE)** は、**G-HUB**を介して動作する独立したTeamGadget Facial Animation / Shape Key Authoring Toolです。

SEはFBX / glTF AssetからShape Key / Morph TargetをImportし、Layered XY Pad Mixing、Preset、Bezier Timeline Editor、Reference Audio Playback、Multi-Character Routing、Compatible TeamGadget EndpointへのリアルタイムShape Key Publishを提供します。

また、**GHEU Offline Facial Bake** WorkflowのFacial Animation Sourceとしても動作します。

> SEではEditingとLive Routingを分離しています。あるCharacter Slotを編集しながら、別のCharacter Slotを独立してG-HUB同期へ参加させることができます。

---

## 概要

SEは **TeamGadget Universal Real-Time Sync System** のFacial Animation Authoring Endpointです。

SEはUnity、Blender、Cascadeur、その他Applicationと**直接通信しません**。  
Live Shape Key Data、Timeline State、Route Ownership、Offline Bake Requestはすべて **G-HUB** を介して処理されます。

```text
ShapeMixer Entangle / SE
          │
          ▼
        G-HUB
          │
          ├── GHEU — G-HUB Entangle for Unity
          └── GHEB — G-HUB Entangle for Blender
```

SEは最大 **5 Character Slots** をサポートします。

各Character Slotは独立して以下を持ちます。

- Imported Shape Key Set
- XY-pad Layer
- Additional Shape Key Assignment
- Preset
- Timeline Track
- Graph Editor State
- G-HUB Facial Route

![ShapeMixer Entangle Main Window](images/se-main-window.png)

---

## 機能

- G-HUB経由のリアルタイムShape Key / BlendShape Publish
- 最大 **5 Character Slots**
- 独立した**EDIT** / **SYNC** Character Selection
- FBX / glTF Shape Key Import
- Layered XY-pad Facial Mixing
- Directional Shape Key Assignment
- Additional Shape Key Control
- AssignmentごとのEnable / INV / Multiplier Control
- Preset作成 / Update
- Multi-Take Animation Workflow
- Bezier Animation Curve Editor
- Timeline Playback / Loop / Range / FPS / Snap / Auto-scroll Control
- WAV / MP3 Reference Audio Import
- Audio Waveform表示
- Audio Offset / Mute / Solo / Volume Control
- Undo / Redo
- `.sme` Project Save / Load
- Canonical G-HUB Timeline同期
- GHEU Offline Facial Bake Requestへの自動応答
- Timeline / Editing向けKeyboard Shortcut

---

## システム要件

- **Windows 64-bit**
- **G-HUB v1.0**
- Live Facial同期を行うCompatible TeamGadget Destination Endpoint
- Unity Offline Facial Bakeでは **GHEU v1.0**

SE v1.0はWindows向けプリビルドApplicationとして配布されます。

Installerは不要です。

---

## 配布

SE v1.0はPortable ZIPとして配布されます。

```text
ShapeMixer_Entangle_v1.0_Windows_x64.zip
```

Release ZIPには適用TeamGadget Licenseが含まれます。書き込み可能なFolderへ展開し、同梱Fileはまとめて保持してください。

SE Source CodeはPublic Binary Distributionには含まれません。

---

# インストール

1. 以下をDownloadします。

```text
ShapeMixer_Entangle_v1.0_Windows_x64.zip
```

2. ZIPを展開します。

3. 以下を実行します。

```text
ShapeMixerEntangle.exe
```

4. Live Shape Key OutputまたはTimeline SyncをEnableする前に**G-HUB**を起動してください。

---

# クイックスタート

1. **G-HUB**を起動します。
2. **ShapeMixer Entangle**を起動します。
3. Shape Key / Morph Targetを持つFBXまたはglTF Character AssetをImportします。
4. **EDIT** Panelで編集するCharacter Slotを選択します。
5. Shape Key ListからShape Keyを**右ドラッグ**し、必要なXY-pad Direction、**ADDITIONAL**、TimelineへDropします。
6. 必要に応じてAnimation Key / Presetを作成します。
7. **SYNC** PanelでLive同期へ参加させるCharacter SlotをEnableします。
8. **UDP: OFF**を押してLive Shape Key Publishingを**ON**にします。
9. Destination TeamGadget Endpoint側で対応Character Slotを接続します。
10. Canonical Timeline同期が必要な場合は**Timeline: ON**をEnableします。

> UDP Publishing中はSYNC SelectionがLockされます。Live同期対象Character Slotを変更する前にUDPをOFFにしてください。

---

# Main Window

SE Interfaceは主に4 Areaへ分かれます。

- 左: Shape Key List / Tab
- 中央: Pad / Preset Authoring Area
- 右: Character / G-HUB / Timeline Control
- 下部: Timeline / Bezier Curve Editor

Current Facial Control、Animation Curve、Audio Waveform、G-HUB Stateを同時に見られるLayoutです。

---

# Character Slots

SEは以下をサポートします。

```text
Character 1
Character 2
Character 3
Character 4
Character 5
```

各Character Slotは独立したFacial Authoring Data / G-HUB Facial Routeを持ちます。

## EDIT

**EDIT** Selectionは現在編集するCharacter Slotを選択します。

EDIT Character変更だけではLive同期のEnable / Disableは変わりません。

## SYNC

**SYNC** SelectionはG-HUB Shape Key Routingへ参加するCharacter Slotを選択します。

複数Character Slotを同時にSynchronizationへEnableできます。

新規ProjectではCharacter 1がDefault参加し、必要に応じてCharacter 2～5をEnableできます。

UDP Publishing ON中は、Active Transmission中のRoute設定変更を防ぐためSYNC SelectionがLockされます。

---

# G-HUB接続

右側G-HUB Control:

```text
[ HUB: 8000 ]
[ UDP: OFF ]
[ Timeline: OFF ]
```

## Control Port

Default:

```text
8000
```

SE Control PortはG-HUB Control Portと一致させてください。

SEが必要とするのはG-HUB Control Portだけです。Live UDP Data PortはG-HUBが自動割り当てします。

通常運用は同一Windows PC内のLocal通信を想定しています。

## UDP

`UDP: ON`で、選択SYNC Character SlotのLive Shape Key Publishingを有効化します。

Compatible Destination EndpointがMatching Character Slotで接続すると、G-HUBがFacial Routeを作成し、必要Data Channelを自動割り当てします。

## Timeline

`Timeline: ON`でG-HUB Canonical Timeline Systemへ参加します。

Timeline SyncはLive Shape Key UDP Publishingとは独立しています。

---

# Shape KeyのImport

以下を使用します。

```text
[ Import FBX/glTF ]
```

Supported FBX / glTF AssetからShape Key / Morph Target名を読み込みます。

SEはImported Shape Key StructureをFacial Authoring / G-HUB Outputへ使用します。

Model Importを行ってもSE内に3D Previewは作成されません。Imported AssetはShape Key Structure Sourceとして使用されます。

Valid Shape Keyが見つからない場合、SEはCurrent Shape Key Setupを空に置き換えず、そのまま保持します。

---

# Shape Key Control

Shape Key ListにはActive Character Slot向けImported Facial Targetが表示されます。

Shape Keyの主な利用方法:

- XY-pad Directionへ割り当て
- **ADDITIONAL**へ割り当て
- Timeline上で直接Animation

Shape Key Valueは最終Facial State生成時にまとめて評価されます。

## Shape Keyの割り当て

Shape Key Assignmentは、Shape Key Listからの**右Mouse Drag & Drop**で作成します。

基本手順:

1. **EDIT** Panelで編集対象Character Slotを選択します。
2. 左側Listから必要Shape Keyを探します。
3. **右Mouse Button**を押したままShape Key名をDragします。
4. 以下のDestinationへDropします。
   - XY-pad Direction
   - **ADDITIONAL** Area
   - Direct Shape Key Animation用Timeline Area

> Shape Key Assignmentは通常の左Dragではなく**右Drag**です。

AssignmentはCurrent **EDIT** Character Slotに属します。Slotごとに独立Authoring Dataを持つため、Control / Timeline Trackを割り当てる前に対象EDIT Characterを確認してください。

Authoring ControlへShape Keyを割り当てても、それだけではLive OutputはEnableされません。Live Routingは**SYNC** Character Selectionと`UDP: ON`で別管理します。

XY-padでは同じDirectionへ複数Shape Keyを割り当てられ、各AssignmentのEnable / INV / Multiplierを独立調整できます。

---

# XY Pad

SEはLayered XY PadでExpression Controlを行います。

Padには以下ZoneへShape Keyを割り当てられます。

```text
UP
DOWN
LEFT
RIGHT
UP-LEFT
UP-RIGHT
DOWN-LEFT
DOWN-RIGHT
ADDITIONAL
```

Shape Key Listから必要Zoneへ**右Drag**します。

同じDirectionへ複数Shape Keyを割り当てられます。

PadはPuck PositionとAssignment設定に応じてShape KeyをMixします。

**XY Pad自体もTimelineへ割り当て可能**です。XY Control Area上にMouseを置き、**XY Areaそのものを右DragしてTimelineへDrop**します。

これによりActive **EDIT** Character Context向けXY-pad Animation Trackが作成され、Pad MotionをKey化し、対応Child CurveをBezier Curve Editorで編集できます。

---

## Assignment Control

各Assignmentでは以下Controlを利用できます。

- Enable
- INV
- Multiplier
- Current Value

1つのPad Directionから複数Facial Targetを異なるDirection / StrengthでDriveできます。

---

# Pad Layers

複数Pad Layerを作成できます。

Layer例:

```text
EYE
BROW
MOUTH
CUSTOM
```

Layer名は自由に変更できます。

大規模Facial Rigを小さなControl Groupへ分割できます。

---

# Presets

SEはCurrent Pad Configuration向けPresetをサポートします。

Preset Controlから以下を行えます。

- Preset作成
- Preset適用
- Existing Preset Update
- Rename / Remove

Presetは作成済みFacial Control Stateを保存し、素早くRecallできます。

---

# Timeline

下部AreaにはSE Animation Timeline / Bezier Curve Editorがあります。

Timeline機能:

- Multiple Takes
- Shape Key Track
- XY-pad Track
- Audio Track
- Previous / Add / Next Key Navigation
- Play / Pause
- Playback Speed
- Loop Playback
- Auto-scroll
- Snap
- Playback Range
- Configurable FPS
- Graph Track Selection
- Timeline Head Context MenuからPreset Stamping

Current Facial ResultはTimelineとActive Character SlotのAuthoring Dataから評価されます。

Timeline AreaはSEのMain Animation Workspaceです。Take切替、Track選択、Waveform Timing Preview、Key Navigation、Graph EditingをCurrent Character Slotから離れずに行えます。

## ControlをTimelineへ割り当て

SEはIndividual Shape Key / Complete XY Padの両方をTimelineへ直接割り当てられます。

### Shape Key Track

Shape Keyを直接Animationするには、左ListからShape Keyを**右Drag**しTimeline AreaへDropします。

Active **EDIT** Character ContextへDirect Shape Key Animation Trackが作成され、TimelineでKey化後、Bezier Curve Editorで調整できます。

XY Pad / **ADDITIONAL**を経由せずIndividual Facial Targetを直接Animationしたい場合に使用します。

### XY-Pad Track

XY PadをControlとしてAnimationするには、**XY Control Areaそのもの**へMouseを置き、Areaを**右DragしてTimelineへDrop**します。

Active **EDIT** Character ContextへXY-pad Animation Trackが作成され、Pad X/Y Motionを時間方向にAnimationできます。Padへ割り当てられた全Shape Keyが同じPad Movementに追従します。

生成XY-pad Curveは他Timeline Dataと同様Bezier Curve Editorで編集できます。

> Timeline Assignmentも**右Drag**です。XY PadをDragするとは、Pad周囲のIndividual Shape Key LabelではなくXY Control Areaそのものを掴む操作です。

## Timeline Head / Ruler操作

Timeline HeadはCurrent Frameを示します。

Timeline Controlから以下を行えます。

- Previous Keyへ移動
- Current FrameへKey追加
- Next Keyへ移動
- Play / Pause
- Loop ON / OFF
- Playback Speed変更
- Auto-scroll ON / OFF
- Snap ON / OFF
- Start / End / FPS調整

さらにTimeline Head / Rulerは**Right-click Preset Stamping**をサポートします。

Preset StampingではCurrent FrameへPreset Eventを直接配置でき、同じFacial Poseを毎回手作業で再構築せずTiming / Blockingできます。

---

# Takes

1つの`.sme` Project内で複数Animation **Take**を持てます。

可能な操作:

- Take作成
- Take削除
- Take Rename
- Take切替

各Takeは独立Animation Track Dataを保持します。

Graph Editor設定も対応Take / Character Contextごとに保持されます。

---

# Bezier Curve Editor

Shape Key / Pad AnimationはBezier Curveで編集できます。

Selected Graph TrackはTimeline Playhead、Current Frame、Audioがある場合はReference Audio Waveformと一緒に表示されます。

![SE Bezier Curve Editor Context Menu](images/se-bezier-context-menu.png)

Bezier Curve EditorはSEの主要Authoring Toolの1つです。Facial Timingの微調整、Expression Shape、Cleanup、Pad / Preset / Direct Keyで作ったRough Performanceの詳細調整に使用します。

## Core Editing Behavior

Graph Editorの主な操作:

- Key Selection
- Key Dragging
- Bezier Tangent / Handle Editing
- Copy / Paste
- Delete
- Alignment / Curve Editing
- Snapping
- Frame Range Display
- Waveformを見ながらTiming調整

Graph上でTiming / Valueを直接編集できます。

- Horizontal Axis = **Time / Frame**
- Vertical Axis = **Value**

通常Shape Key Curveだけでなく、XY-pad / Additional Facial Controlから生成されるChild Curve編集にも利用できます。

## Tangent Handle / Gizmo

Key選択時、詳細Curve Editing用Bezier Handleが表示されます。

以下を調整できます。

- Ease-in / Ease-out Timing
- 急激なTransitionのSmooth化
- Facial Accentの強調
- Neighbor Key間Interpolationの形状

Local Graph Editing Gizmo:

- **X** = Time
- **Y** = Value

Handle Direction / Spacing調整時に、Timing / Amplitudeのどちらを変更しているか把握しやすくなります。

## Right-Click Key Editing Menu

Graph上の右ClickからSelected Key向けQuick Editingを実行できます。

- **Smooth Handles (Auto)**
- **Align Keys (Vertical/Horizontal)**
- **Jitter / Randomize...**
- **Delete Selected Keys**

### Smooth Handles (Auto)

Selected KeyのBezier Handleを自動Smooth化します。Manual EditingでCurveが不均一になった場合にCleanなInterpolationへ素早く戻せます。

### Align Keys (Vertical/Horizontal)

Key Groupを整列します。

- **Vertical Alignment** — 複数Keyを同じValueへ
- **Horizontal Alignment** — 複数Keyを同じFrameへ

Cleanup、Rhythmic Facial Beat、Phoneme Timing、Blockingで便利です。

### Jitter / Randomize...

Selected KeyへControlled Variationを追加します。微妙なFacial Irregularity、Texture、機械的な反復を崩す用途に使えます。

### Delete Selected Keys

Active Graph TrackのSelected Keyを削除します。

## Timeline / Presetとの関係

Graph EditorはTimeline Workflowと密接に連携します。

代表Workflow:

1. XY PadまたはPresetでFacial PoseをBlock
2. Timelineへ配置 / Stamp
3. Bezier Curve EditorでMotionを調整

Timeline HeadのRight-click Preset Stampingにより、Presetは単なるPose RecallだけでなくTimed Animation Building Elementとして利用し、その後Graph Editorで仕上げられます。

## 実用例

Bezier Curve Editorは以下に特に有効です。

- Lip / Mouth Timing Cleanup
- Brow Emphasis / Asymmetry調整
- Eye Motion Shape調整
- Expression間Transition Smooth化
- Dialogue / Musicに対するBeat調整
- GHEU Offline Facial Bake前のData調整

---

# Reference Audio

以下からReference AudioをImportします。

```text
[ Import Audio ]
```

対応File:

```text
WAV
MP3
```

SEはTimelineへWaveformを表示し、以下Audio Controlを提供します。

- Offset
- Volume
- Mute
- Solo
- Timeline同期Playback
- Local Scrub Preview
- 他G-HUB Timeline Owner追従中のReference Audio Playback

他対応EndpointがCanonical Timeline Ownerの場合、SEはPassive Timeline Followerとして動作し、Reference AudioはRemote Play / Pause / Scrub / Seek Stateへ追従します。

Audio File自体は`.sme` ProjectへEmbedされず、ProjectからSource FileをReferenceします。

Project Load時に参照Audio Fileが見つからなくても、Audio Track情報は削除せず保持します。

---

# Project Files

SE Project File Extension:

```text
.sme
```

ProjectはCharacter Slot Data、Shape Key Setup、Pad、Preset、Take、Animation Curve、Timeline Setting、Audio Track ReferenceなどのAuthoring Stateを保存します。

Top Menu:

```text
[ New ] [ Load ] [ Save ] [ Save As ]
```

---

# Undo / Redo

通常Editing History:

```text
[ Undo ]
[ Redo ]
```

Interactive Dragは過剰なHistory Entryを生成しないよう、Common Edit Operationを1 User OperationとしてGroup化します。

---

# Canonical Timeline同期

SEはG-HUB Canonical Timeline Systemへ参加できます。

Timeline Sync有効時、以下Stateを同期できます。

- Current Timeline Time / Frame
- Play
- Pause
- Stop
- Scrub / Seek
- Playback Range
- Frame Rate

SE自身がActive Timeline Ownerになることも、G-HUB経由で受信したTimeline Stateへ追従することもできます。

他EndpointへFollowしている間、SEは競合する2つ目のTimeline Clockを動かしません。Canonical Timeline StateをAuthoritativeとして扱い、Reference Audioも受信Playback / Scrub Stateへ追従します。

Timeline同期はLive Facial UDP Outputとは独立しています。

---

# Live Facial同期

Live Facial Outputには**SYNC** Panelで選択したCharacter Slotを使用します。

各Enabled Character Slotについて、SEはG-HUB経由の独立Facial Routeを維持します。

通常Live Operationでは変更されたShape Key Valueのみ送信すればよく、Route Establishment / Reconnection時はCurrent Authoritative Stateを復元します。

Destination Componentが受信Shape Key / BlendShape ValueをTarget Characterへ適用します。

---

# GHEU Offline Facial Bake

SEはGHEU Offline Facial Bake WorkflowのFacial Animation Sourceです。

```text
ShapeMixer Entangle / SE
          │
          ▼
        G-HUB
          │
          ▼
       GHEU
          │
          ▼
BlendShape AnimationClip
```

Offline Facial BakeはGHEU側から開始します。

SEは対応Character SlotへのRouted Bake Requestへ自動応答し、RequestされたCanonical TimeでSE Timelineを評価して、作成済みShape Key ValueをG-HUB経由で返します。

Source / Destination Frame Rateは一致不要です。GHEU Bake FPSとSE Timeline FPSが異なる場合、SEはRequest Canonical Timeを対応Local SE Frameへ変換してFacial Animationを評価します。

Unity側Final Resultは**BlendShape-only AnimationClip**です。

Body AnimationはGHEUの**FBX Bridge**で別処理します。

---

# Keyboard Shortcuts

| Action | Shortcut |
| --- | --- |
| Previous key | `A` |
| Add key | `S` |
| Next key | `D` |
| Delete selected keys | `Delete` |
| Clear selection | `Esc` |
| Play / Pause | `Space` |
| Save project | `Ctrl+S` |
| Copy keys | `Ctrl+C` |
| Paste keys | `Ctrl+V` |
| Undo | `Ctrl+Z` |
| Redo | `Ctrl+Y` |
| Apply selected preset | `Enter` |

---

# トラブルシューティング

## SEがG-HUBへ接続できない

以下を確認してください。

- G-HUBが起動している
- SE / G-HUBが同じControl Portを使用している
- Windows Firewall / Security SoftwareがLocal通信をBlockしていない

---

## UDPはONだがFacial DataがDestinationへ届かない

以下を確認してください。

- 対象Character SlotがSE SYNC PanelでEnable
- Destination EndpointがG-HUBへ接続済み
- DestinationがMatching Character Slotを使用
- 対応Facial RouteがG-HUB上に存在
- Destination EndpointでShape Key同期がEnable

---

## Imported ModelにShape Keyが表示されない

以下を確認してください。

- Source AssetにMorph Target / Shape Keyが実際に含まれる
- FBX / glTF ExportにFacial Targetが含まれる
- 正しいCharacter Assetを選択している

---

## Timelineが他Applicationへ追従しない

以下を確認してください。

- `Timeline: ON`がEnable
- 他ApplicationでもG-HUB Timeline SyncがEnable
- 両Applicationが同じG-HUB Instanceへ接続

---

## Audioが再生できない

以下を確認してください。

- WAV / MP3 Source Fileが存在
- Windows Audio ComponentからFileを開ける
- Audio TrackがMuteされていない
- TimelineがAudio Track Active Time Range内にある

---

# ライセンス

ShapeMixer EntangleはTeamGadget独自Softwareとして配布されます。

Binary DistributionにはRelease ZIP同梱の`LICENSE`が適用されます。

Third-party Software ComponentにはそれぞれのLicenseが適用されます。

---

# Third-Party Notice

ShapeMixer Entangleは**NAudio**、**Silk.NET.Assimp**などのThird-party Software Componentを使用します。

各Copyright / License条件は引き続き適用されます。

ShapeMixer Entangle、G-HUB、GHEU、GHEB、GHEC、関連TeamGadget製品名は独立したTeamGadget Projectです。

Third-party File Format / Application / Product / Trademarkへの参照は、Compatibility / Interoperabilityの識別目的のみです。

Third-party製品名 / Trademarkは各権利者に帰属します。

---

# Project

**TeamGadget**  
**ShapeMixer Entangle v1.0**
