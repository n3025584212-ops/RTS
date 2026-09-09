# River Town — 近景房屋结构与材质批次

日期：2026-09-09。施工起点：`1472a4430fc5d9c699b6c817b04e0ff1bb5a39f9`。
试验场景：`res://scenes/production/RiverTownStructureStudy.tscn`。

**VISUAL_ACCEPTANCE=REJECTED_AS_QUALITY_UPGRADE**

用户指出本批仍没有本质画质提升。本批已停止施工，作为独立试验保留。
主场景与其房屋、材质、生成器、主预览均恢复到本批开始前的 `1472a44` 状态；
这不代表先前批次获得验收。试验场景采用继承与替换单栋房屋的方式，不能覆盖主预览。
视觉最低基线仍为 `d42e6fc2bbe1bad928a16a19caace47dc6e57701` / Run #5。

本次试验把前景房屋的前右侧破坏贯通到楼板、屋顶和山墙，并修正构件材质；这些结构变化没有达到用户要求的整体画质提升。
交付物是运行时加载的 GLB、Godot 材质绑定、生成器和参数。截图仅为证据。
不宣称达到“最高画质”，也不宣称这一个建筑已构成可铺满全图的完整模块库。

## 实际变化

- 墙体破口延伸到屋檐和屋顶，侧面山墙使用有厚度的连续断面；檐口和椽条随破坏区截断。
- 室内增加支撑梁、真实楼板条、楼梯及对应楼板开口、带门洞的隔墙和少量尺度参照家具。
- 坍塌区域保留相连的椽条、横条和楼板片段，断木具有实体断面；烟囱从屋顶延续到地基。
- 瓦片各自具有厚度和搭接，单块几何采样单块瓦片的表面区域；屋脊盖瓦闭合并与坡瓦接合。
- 木材 UV 在每根构件的局部坐标中生成，沿长轴铺设木纹，再合并网格；材质改用木材贴图。
- 独立碎砖与断口砖使用单砖表面区域，墙体砖层保留整墙材质。UV 接缝与实体顶点分开，保留倒角。
- 清除满墙重复的大块剥落纹理，实体灰泥缺失集中在破坏边、窗洞附近、地脚和少量局部剥落处。
- 两套新增 2K 材质为 Poly Haven 的 `wood_planks`（Amal Kumar）和 `plastered_wall_02`（Charlotte Baglioni），CC0。下载 URL、作者和 MD5 见 `assets/visual_slice/profiles/house_material_sources.json`。

## 验证边界

主镜头位置、朝向、FOV、曝光、太阳、天空和雾保持施工起点的配置。
坦克、地面、植被、河水生成函数未修改；草实例数保持 99,020。
新增 `side` 镜头仅用于检查侧面，不改变 `reference` 或 `hero` 镜头。

所有截图由 Godot 4.7.1 Forward+ 在第 32 帧的 `frame_post_draw` 后直接取得，
1920×1080，无后期编辑。硬件为 Intel UHD Graphics，内部渲染比例仍为 1.5，MSAA 4×。

最终证据、模型 SHA-256、导出完整性、运行日志检查和同机数据见
`artifacts/visual_reset/batch02_manifest.json`。该清单完成后才作为本批的正式证据索引。

已完成的施工阶段检查包括正常主镜头、近景、侧面、单独的无贴图实体诊断，
以及平移、旋转、缩放后再次移动的三个实例。实例检查验证共享网格和独立材质，
不能替代正常画面的视觉判断。无贴图诊断不会覆盖正常主预览。

## 复现

仅生成当前房屋，不生成其他场景资产：

```powershell
& 'D:\Agent\frontline-visual-reset\tools\blender-4.5.9-windows-x64\blender.exe' --background --python scripts/production/build_river_town_structure_study.py -- --local-fidelity-profile assets/visual_slice/profiles/hero_house_structure_study.json
```

需要检查归档试验时，显式打开 `res://scenes/production/RiverTownStructureStudy.tscn`；
主场景不会加载该试验。以实际 Godot 4.7.1 引擎运行：

```powershell
& 'D:\godot\Godot_v4.7.1-stable_win64_console.exe' --path . --rendering-method forward_plus --audio-driver Dummy --resolution 1920x1080 res://scenes/production/RiverTownStructureStudy.tscn -- --capture --capture-frame=32 --capture-label=structure_study_review --view=reference
```

查看近景或侧面时用 `--view=hero` 或 `--view=side`，并使用独立标签。
单栋试验资产入口为 `res://scenes/production/RiverTownHeroHouseStructureStudy.tscn`。
其 GLB 按九种材料合并，导入启用 LOD 和影子网格生成。
试验生成器必须指定参数文件，避免无参数时重新生成其他建筑。
本变体的主体尺寸固定为 11.6×8.4 m，两个楼层；不同尺寸建筑的拼装没有验证。

## 尚未解决的内容

道路仍有规则沟槽感，植被仍有均匀铺设感，建筑整体老化和自然差异还可继续改善。
本批没有用降低这些区域质量换取运行速度。
当前核显上的全场景帧率不构成全游戏推广的性能合格证明；应以清单内的实测帧耗时为准。
基线已有的退出时 Texture RID 清理警告需要与新增运行错误区分。

## 性能数据的使用限制

最终试验主镜头的 24 个墙钟样本平均约 541.07 ms，P95 573.51 ms，
绘制调用 2,134，图元统计 38,094,036。本核显环境下依然约为 2 FPS。
本批重新运行的基线记录出现 4,159 个样本，与 24 样本协议不一致，
其均值受额外帧影响，**不能用于性能对比，也不能引用为基线帧率**。
保留该原始记录并标记无效，不从它计算优化百分比。
历史 `baseline_local` 的 473.17 ms 仅作为此前记录，不冒充本轮严格 A/B 测量。
