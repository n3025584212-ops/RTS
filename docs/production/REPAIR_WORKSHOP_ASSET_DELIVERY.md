# FRONTLINE 维修车间资产交付 — 2026-09-12

本轮只补齐一项瓶颈：可近看的工业／维修建筑。交付为一栋完整砖砌维修车间，
以及它的源文件、可重建脚本、LOD 和现有 Hero V2 场景内的实际 Godot 截图。

## 核查基线与范围

- 仓库：`n3025584212-ops/RTS`
- 基线分支：`dev/river-town-local-high-fidelity-v1`
- 固定基线提交：`dfc4b64e9bbc2a1c8f5d1032e92912195c575f07`
- 引擎：实测 `4.7.1.stable.official.a13da4feb`，Vulkan Forward+。
- 因本机旧工作副本缺少 Hero V2，使用 GitHub API 拉取限定目录的固定提交快照，
  并按 Git blob SHA1 校验；复用本机已匹配的资产字节。原工作副本及其未提交修改未被覆盖。
- 已读取任务文档、Golden Scene 资产清单、Hero V2 attribution、bootstrap 脚本，
  以及准确路径 `scripts/production/river_town_hero_shot_v2.gd` 和
  `scripts/production/river_town_visual_slice.gd`。前者继承后者。
- 补充核查只限房屋构建脚本、现有工业资产调用段、Hero V2 制作脚本和导入配置。
  没有修改地图、AI、玩法或 Battle01。

## 判断：真正限制画质的资产问题

| 类别 | 实际证据 | 保留／加工／重新获得源模型 |
|---|---|---|
| Hero Urban Ruin | 205,400 三角面、7 材质；原始 4K 模块 UV/PBR、独立门窗／檐口，补充墙厚、断面、楼板、梁和坍塌堆 | 原样保留。高质量来源是结构与源材质一起成立，而非单纯面数或更强曝光。后续可加工具体断面 UV／材质与结构支承 |
| Abrams V2 | 291,342 三角面、28 材质；原始 atlas、制造倒角、履带／橡胶／裸钢分材质 | 原样保留；不能用统一涂色或低模坦克替代 |
| Hero House | 原始 ruined 70,592 三角面；HF 版本 300,930；已有实际瓦片、开口与破坏结构 | 均保留。历史增加细节的批次没有被用户接受为新视觉底线，不能仅按面数宣称升级 |
| 普通住宅 | intact 18,568／damaged 21,411 三角面、各8材质；现有构建脚本的主房型重复，运行时按材质名称覆盖；源 GLB 本身主要是常量材质 | 保留为中远景。近景加工应采用不同建筑平面、专属门窗／檐口、连贯纹理尺度与真实破坏逻辑；更强噪声不能替代这些 |
| 工业／维修 | 核查的 `create_far_industry()` 用 38×14×30 m 等 BoxMesh 及圆柱烟囱；Hero V2 目录没有独立维修／仓储模型 | 远景用途可保留。近景必须取得工业源模块并重新组成完整建筑。本轮解决这一项 |
| 仓储 | 本次限定目录内未发现达到 Hero V2 标准的独立完整仓库 | 需要货台高度、货运门、柱网、屋架、屋面排水和附属空间；可延续本轮源材质体系，但要新建仓库布局 |
| 农业建筑 | 本次限定范围未发现独立高质量农机棚／粮仓／谷仓资产；旧本地 farmhouse 研究文件未在固定基线 Hero V2 清单中 | 不能把住宅改比例当谷仓。需木构或钢构源、真实宽跨入口、屋面和储存结构；另行制作，不在本轮扩展 |

`artifacts/industrial_workshop/asset_audit.json` 提供逐资产面数、材质图绑定、
UV／法线／切线和 SHA256。基线 Abrams 原始 GLB 没有导出切线，但 Godot 导入配置
启用了 ensure_tangents；不能把“文件内缺切线”直接说成“运行时切线错误”。

## 实际完成的建筑

12×12 m 主体，双 3.32×2.74 m 维修门，4.2 m 檐口、6.1 m 主屋脊。
用途是轻型车辆及设备维修，门洞不适合 Abrams 通行，未通过缩小 Abrams 配合建筑。
包含四面砖墙、24 cm 向内封闭厚度及源开口进深、墙垛、基础、地坪、入口坡板、
独立人员门、侧门雨棚及三角托架、钢屋架、檩条、搭接波纹钢屋面、脊盖、山墙泛水、
开口天沟、带偏移弯头落水管、通风管／雨帽、配电盒／明线管、工作台和储物架。
门保持关闭；本轮交付没有门动画、室内玩法或游戏碰撞系统。

所有装饰和建筑部件是导出的真实网格。项目运行时没有用 BoxMesh 代替新建筑。
完整包围盒（含雨棚、坡板、通风装置）约为 Godot XYZ **14.02×7.13×14.64 m**。

## 材质处理和 LOD

1. 使用 James Ray Cock 的 Poly Haven **Modular Factory Facade** CC0 原始模块。
   模块保持原始 UV；上部墙带裁切源墙板而非拉伸砖纹。测得源墙板纹理密度为
   1/3 UV单位/米，自建山墙与墙垛统一到同一密度，避免上下砖纹大小不一致。
2. 显式重建导出可识别的 PBR 图：albedo=sRGB；OpenGL 法线与 ARM=Non-Color；
   ARM 的 R=AO，G=roughness，B=metallic。砖／混凝土不设金属；门板依源 mask。
   修正源玻璃材质的法线图绑定，保留脏玻璃 atlas 的不透明外观。
3. 屋面采用 Charlotte Baglioni 的 **Corrugated Iron 03** CC0 4K PBR。
   高度图生成真实屋面起伏，UV 以2 m实物尺度铺设，增加钢板厚度和搭接。
4. 先进行实际倒角、墙厚和三角化，再分别生成 LOD。细管线、螺钉、字牌和内部
   次结构按层级移除，主要墙体、门窗及屋顶轮廓保留。远LOD实拍曾发现对薄门片
   直接减面会产生空洞，最终明确保护 door/window 插入件，把减面量放在墙面和屋面。
   导出后网格验证清理退化面；这也是保留实际LOD截图而非只看面数的原因。
5. 三份 GLB 保留几何，引用同一个 `textures/`：18 张4K图，共87,153,265字节。
   保持4096分辨率，以 JPEG quality92、4:4:4 编码，不对法线或ARM做色彩变换。
   原始无再压缩贴图仍打包保存在 Blender 源文件，源下载也可按锁文件重建。

| LOD | 三角面 | 材质表面 | GLB 字节 | 默认距离 |
|---|---:|---:|---:|---|
| 0 | 228,000 | 9 | 24,525,144 | 0–45 m |
| 1 | 101,985 | 9 | 11,964,548 | 45–100 m |
| 2 | 45,230 | 9 | 5,046,696 | 100 m以上 |

`RepairWorkshop.tscn` 管理 LOD 距离和3 m边界缓冲，三者共享 LOD0 材质资源。
Godot 导入还在各表面生成20／19／17个内部简化层级条目。
这些是局部资产验证结果，不是全地图批量部署性能保证。

## Godot 接入与证据

- 资产实例：`res://scenes/production/RepairWorkshop.tscn`
- 验证场景：`res://scenes/production/RiverTownWorkshopValidation.tscn`
- 后者继承现有 Hero V2 完整场景，并在 `(23, height_at(23,-7)+0.10, -7)` 添加一栋。
  被建筑占用的草实例移到旁边；99,041个草实例数量不变。原始 Hero 建筑、坦克、
  地形、光照、材质脚本均不改写。自动 LOD 在新节点内实现。
- Forward+、4×MSAA、原1.5倍内部渲染比例、原天空／雾／SSAO／SSIL 保留。
- 截图均在32帧稳定后，通过 `Viewport.get_texture().get_image()` 实际读回。
  分辨率1920×1080，无后期修图、无 AI 生成截图。
- `artifacts/visual_reset/industrial_baseline/`：新施工前的原 Hero V2。
- `workshop_front/`、`workshop_rear/`：四面体量、排水和墙窗检查。
- `workshop_overview/`：车间与现有 Urban Ruin／Abrams 共存全景。
- `workshop_detail/`：门窗、材质与接缝近看。
- `workshop_lod1/`、`workshop_lod2/`：同机位强制LOD用于检查简化误差，不是推荐的近看LOD。
- `workshop_reference/`：原Hero机位添加建筑后的保留性对照。

本机是 Intel UHD Graphics。高画质完整场景较慢，不能用 `_process delta` 的钳制值
推算真实性能；记录采用墙钟时差。原基线退出时已有7条Texture RID未释放告警，
作为已有问题记录，不把它算作这栋新建筑的画质提升或性能结论。
初次快照导入因项目默认指向未包含的 Battle01 主场景报缺文件；后续使用上面的
明确生产场景路径导入和运行，没有为此读取或重建 Battle01。

## 重建与继续制作

依赖：Blender 4.5.9 LTS、Python3及Pillow／NumPy、Godot4.7.1。脚本支持传入各执行文件路径。
在仓库根目录：

```powershell
pwsh -File tools/industrial/rebuild.ps1
pwsh -File tools/industrial/run_validation.ps1 -View workshop -Label workshop_review
pwsh -File tools/industrial/run_validation.ps1 -View overview -Label workshop_overview_review
pwsh -File tools/industrial/run_validation.ps1 -Interactive
```

`res://scenes/production/WorkshopEvidenceBatch.tscn` 默认只拍远LOD修复检查，
避免重复消耗资源。确实需要整套证据时才传入 `-- --all-views`；它重用同一完整世界，
逐视图等待32帧。无需 `--capture` 参数。远LOD修复不改变LOD0/1，原近景证据按
对应LOD的SHA256复用，仅远LOD重拍。

最终交付保留已经实拍的LOD0／LOD1导出文件，只更新LOD2。Blender重新导出时
切线顶点拆分／浮点排序可能产生字节差异，不能保证GLB逐字节重建相同；最终文件
以交付清单SHA256为准，截图保留各自实际运行文件的哈希，不改写历史采集记录。

可编辑源：`assets/visual_slice/industrial_workshop/source/repair_workshop_source.blend`。
这个打包源文件约204 MB，随本地完整交付保留；超过GitHub普通文件100 MiB限制，
仓库使用可重建源方案：提交原工厂glTF／BIN几何源、固定贴图锁文件和完整bpy脚本。
运行 `rebuild.ps1` 会重新产生可编辑且打包贴图的 `.blend`。
该目录的 `.gdignore` 让 Godot 使用导出的 GLB，避免自动重复导入 Blender 工程。
下载脚本默认读取 `tools/industrial/manifests/` 的固定 URL、MD5与SHA256，
下载失败或哈希变化时退出；不会静默换源或生成低模替代品。

继续做仓库时保留下载、PBR、UV、LOD、GLB打包和验证工具，重新定义装卸货台、
大门、柱网和屋架布局；做农机棚时换成适合的结构源与跨度。每栋都重新建立有用途的
平面与立面，不通过修改这一栋的宽高参数冒充新资产。先检查几何／材质近景，再回到
固定Hero机位比较，最后才讨论更多实例和全地图预算。

本次交付是新增资产及可复用制作流程。画质判断基于实际近景、背面与同场景对照；
最终艺术验收仍由用户决定，不把自动校验通过当作人工批准。

数值验证额外清除了LOD0／LOD1的16／8个零面积三角形，并为LOD2一个未定义切线
建立与原法线正交的切线基。三个最终GLB均为零退化面、零非有限数值，法线／切线
长度误差小于0.001。细节见 `geometry_validation.json` 和 `export_sanitation.json`。
