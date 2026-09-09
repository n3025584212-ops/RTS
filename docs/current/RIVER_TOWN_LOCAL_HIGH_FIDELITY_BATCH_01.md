# River Town — 实体细节与可复用组件批次

日期：2026-09-09。目标分支：`dev/river-town-local-high-fidelity-v1`。
视觉基线：`d42e6fc2bbe1bad928a16a19caace47dc6e57701`，FRONTLINE River Town Visual Slice / Run #5。

本批实际产物是 Godot 场景、网格资产、材质和生成参数。主任务保持 ACTIVE；本批不能代表整个游戏的画质或性能已验收。

**VISUAL_ACCEPTANCE=REJECTED_AS_QUALITY_UPGRADE**

用户复核：本批没有带来本质性的画质提升。技术验证、实体增加和组件可复用不构成视觉验收。本提交仅保存可审查、可回退的施工检查点；不得作为全面推广的高画质标准。下一批应优先解决近景主建筑的资产造型与成套材质质量，先取得同镜头下明显改善，再推广实现。

## 实体施工

- 房屋：固定网格删面改为连续断裂轮廓；约 30 cm 厚砖墙的破口封边、36 mm 厚墙皮及断面、交错露砖、7 mm 实体倒角。屋瓦具有 18 mm 厚度和 35 mm 搭接高差，保留破瓦、椽条、内部楼板与断木。额外细节采用独立随机状态，不重新排列原屋瓦损坏分布和场景植被。
- 地面：保留近区 16 cm 网格；在约 6.4 × 44 m 的车辆通道增加 8 cm 网格，真实承载车辙、32 cm 节距的履带压纹与挤土脊。删除该范围下面重复覆盖的粗网格面，避免两套地表互相穿插。履带下泥土按压实状态减小松软凸块的振幅，保留真实表面采样密度。
- 积水：凹坑写入同一地形高度函数；水面保持水平，边缘通过实体泥岸和深度过渡形成，避免漂浮圆片。路中碎石移到履带通道外侧。
- Abrams：读取源金属度贴图及其正确通道，按材料名称区分涂装、橡胶、机械金属、灯具；保留原始迷彩贴图。低位湿泥、上表面灰尘与裸露金属具有不同粗糙度。没有新增虚构坦克结构。

## 复刻入口

1. **直接放置房屋**：实例化 `res://scenes/production/RiverTownHeroHouseHF.tscn`。材质和实体资产随场景实例加载；对象坐标采样使污渍与砖缝随房屋一起移动、旋转、缩放，无逐帧修补。
2. **批量生成变体**：复制 `assets/visual_slice/profiles/hero_house_high_fidelity.json`，更改 `output_asset` 和 `seed`，按需要设置墙皮厚度与倒角。保留默认 JSON 即可重建本批模型。
3. **沿其他道路复用**：使用 `res://assets/visual_slice/profiles/road_high_fidelity.tres`；将道路局部横向距离和沿路距离传入 `displacement()`。将其用于网格高度及接地查询，保证装饰物和车辆位置采用同一地面。
4. **网格复用**：三个房屋实例通过平移、旋转、统一缩放及入树后再次移动检查；每栋仍为 8 个网格部分，实例共享 Mesh 资源、保留独立可变材质。Godot GLB 导入启用 `generate_lods` 和 `create_shadow_meshes`。

生成命令（Blender 4.5.9）：

```powershell
& 'D:\Agent\frontline-visual-reset\tools\blender-4.5.9-windows-x64\blender.exe' --background --python scripts/production/build_river_town_kit.py -- --local-fidelity-profile assets/visual_slice/profiles/hero_house_high_fidelity.json
```

省略新参数时，原生成器的三个默认资产生成入口保持原行为。该命令只生成配置指定的资产。

## 实机验证

- Godot **4.7.1 stable official / a13da4feb**，Vulkan **Forward+**，本机 **Intel UHD Graphics**。
- 所有证据直接由 `Viewport.get_texture().get_image()` 在 `frame_post_draw` 后保存，**1920 × 1080**，无后期图像处理。
- Run #5 原始产物已下载留存；另将其场景和着色器冻结，在同机以相同第 32 帧协议复现，与本批同镜头结果比较。
- 主镜头位置、朝向、FOV、曝光、太阳参数、ACES、天空、SSAO/SSIL、雾、反射探针、1.5× 内部渲染比例、MSAA 4× 均保留。植被 **99,020** 个草实例，数量保持一致。
- 最终正常材质主镜头、建筑近景、地面近景和无贴图实体诊断均完成真实运行；最终渲染日志无脚本或着色器错误。退出时仍有与基线相同的 7 个 Texture RID 清理警告。
- 复刻校验在真实 Forward+ 下运行通过，无错误。Headless dummy renderer 在销毁材质时报告空 material，因此不能将该模式作为本检查的运行证据。
- 已修复证据输出：其他镜头和无贴图诊断不再覆盖主预览。

运行主镜头：

```powershell
./scripts/production/run_river_town_slice.ps1 -CaptureFrame 32 -Label local_high_fidelity
```

建筑近景用 `-View hero -Label hero_review`；地面近景用 `-View ground -Label ground_review`。只有诊断时使用 `-GeometryProof`，该图不能作为最终画质图。

复刻校验：

```powershell
& 'D:\godot\Godot_v4.7.1-stable_win64_console.exe' --path . --rendering-method forward_plus --audio-driver Dummy --script res://scripts/production/verify_local_fidelity_instances.gd
```

## 观察结果与成本

同镜头可观察到：房屋破口不再是方格阶梯边，屋瓦具有独立搭接轮廓，墙皮破损与露砖位置由网格定义；Abrams 原迷彩、护板和机械部位的材质更容易区分；地表有连续实体车辙和受地形约束的浅水。

| 同机第 32 帧协议 | Run #5 复现 | 本批主镜头 |
|---|---:|---:|
| 绘制调用 | 2,195 | 2,129 |
| 渲染图元（包含渲染统计所计通道） | 36,402,241 | 37,968,011 |
| 墙钟帧间隔平均值，24 个样本 | 473.17 ms | 507.37 ms |
| 墙钟帧间隔 P95 | 483.18 ms | 536.13 ms |

这是局部高画质构建，不是可全图铺开的性能认证。本机保持最高采样和植被密度时约为 2 FPS；本批短窗口平均成本比同机基线高约 7.2%。不能用 `_process(delta)` 中约 133 ms 的截断值宣称更高帧率。后续全图推广需要使用距离 LOD、可见区域分块和批次预算，同时保住已验证的近景实体标准。

本批未迁移到 Battle01，未修改玩法，也未审计无关场景或脚本。

## 证据

- 主镜头：`artifacts/visual_reset/hf_final_reference/river_town_actual_1920x1080.png`
- 正常材质建筑近景：`artifacts/visual_reset/hf_final_hero/river_town_actual_1920x1080.png`
- 正常材质地面近景：`artifacts/visual_reset/hf_final_ground/river_town_actual_1920x1080.png`
- 无贴图实体诊断：`artifacts/visual_reset/hf_final_geometry/river_town_actual_1920x1080.png`
- 同机基线：`artifacts/visual_reset/baseline_local/river_town_actual_1920x1080.png`
- 每个目录的 `runtime_metrics.json` 记录相机、引擎和 GPU；`replication_validation.json` 记录复用检查。
- `evidence_manifest.json` 记录源 Run #5、最终资产和截图的 SHA-256。

本批已被用户指出缺少本质画质提升；不将编译成功、实例复用或运行通过等同于画质验收。
