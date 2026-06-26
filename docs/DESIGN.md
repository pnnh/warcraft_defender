# Warcraft Defender Style Game - Design Document (DESIGN.md)

**项目名称**：Warcraft Defender 风格休闲奇幻塔防游戏 Demo  
**版本**：v1.0  
**最后更新**：2026-06-26  
**用途**：作为 AI 素材生成（尤其是 Ludo.ai MCP / API）的核心参考文档，确保全游戏视觉风格高度一致。

---

## 1. 项目整体视觉风格定义

### 1.1 核心风格关键词（必须严格遵守）
- **Cute Cartoon 2D**（可爱卡通 2D）
- **Western Cartoon** / **Stylized Cartoon**
- **Angled Top-Down** / **轻微 2.5D 俯视视角**
- **Fantasy Defense Game**（奇幻防御主题）
- **Clean Black Outlines** + **Flat Colors with Soft Shading**
- **Vibrant & Cheerful**（明快、轻松、亲和）

**风格定位**：休闲向、可爱向、移动端友好。类似《Plants vs. Zombies》+ 现代奇幻卡通的结合体。避免写实、黑暗奇幻、像素风（除非特别指定）。

### 1.2 设计原则
- **圆润优先**：所有形状（树冠、角色身体、建筑）必须圆润柔和，无尖锐棱角。
- **简化设计**：细节适度，易于识别，适合休闲玩家。
- **高对比度**：明亮饱和色彩 + 清晰轮廓，便于移动屏幕阅读。
- **一致性至上**：全游戏所有资产必须使用相同艺术风格、线条粗细、阴影处理方式。
- **性能友好**：资产文件小、易于打包 spritesheet，适合移动端。

---

## 2. 颜色调色板（Color Palette）

### 主色调（严格使用以下色系）
- **草地/背景绿**：#4CAF50（主绿）、#66BB6A（亮绿）、#388E3C（深绿）
- **树木渐变**：从 #2E7D32 到 #81C784 的多个绿色
- **大地/围栏棕**：#795548（主棕）、#A1887F（浅棕）、#5D4037（深棕）
- **敌人红**：#E53935（主红）、#EF5350（亮红）、#C62828（深红）
- **英雄/平台蓝**：#42A5F5（主蓝）、#64B5F6（亮蓝）、#1565C0（深蓝）
- **地面路径**：#D7CCC8（浅米色/浅棕）
- **UI 辅助色**：白色、黑色、#FFEB3B（黄色高亮）

**使用规则**：
- 优先使用高饱和度明亮色。
- 阴影使用同色系深 20-30% 的颜色。
- 高光使用同色系亮 15-25% 的颜色。
- 避免使用灰色调或低饱和色（除非特殊 VFX）。

---

## 3. 视角与构图规范

- **主视角**：Angled Top-Down（带轻微透视的俯视）
- **角色表现**：英雄多为 3/4 侧面或侧面；敌人可 3/4 或正面。
- **分层结构**：
  1. 背景层（草地、远景树）
  2. 中景层（树木、敌人、路径）
  3. 前景层（木栅栏、英雄平台）
- **场景元素间距**：保持合理留白，避免拥挤。
- **对称与平衡**：关键元素居中或对称放置。

---

## 4. 资产分类与规格

### 4.1 背景类（Backgrounds）
- **类型**：fixed_background、side_scrolling_background
- **推荐尺寸**：1920x1080 或 1280x720（可根据需要缩放）
- **内容**：草地 + 路径 + 散布树木 + 远景栅栏
- **Ludo.ai 参数**：`image_type= fixed_background` 或 `side_scrolling_background`

### 4.2 道具类（Props / Assets）
- **树木**：生成 6~8 个变体（不同大小、绿度、角度）
- **木质围栏 + 大门**：带简单纹理和接缝
- **平台/塔**：蓝色结构 + 靶心 + MAX 标签
- **其他**：箭矢、特效占位符（后期单独生成）
- **Ludo.ai 参数**：`image_type=asset` 或 `sprite`

### 4.3 角色类（Characters / Sprites）
- **英雄**：小型可爱弓箭手/守卫
- **敌人**：红色小恶魔/兽人（持斧），大头小身，可爱化凶恶表情
- **规格**：主角色建议 128x128 或 64x64 基础尺寸（动画时保持一致）
- **Ludo.ai 参数**：`image_type=sprite`

### 4.4 动画类（Animations / Spritesheets）
- **帧数推荐**：9、16、24、36 帧（优先 24 帧平衡质量与大小）
- **循环**：行走、待机 = seamless loop；攻击、死亡 = 单次播放
- **动作列表**（优先级）：
  - 敌人：Idle → Walk（左右） → Attack（挥斧） → Death
  - 英雄：Idle → Attack（射箭） → Victory（可选）
- **Ludo.ai 工具**：先用 `generatePose` 生成关键姿势，再用 `animateSprite`

### 4.5 UI 类（UI Assets）
- **元素**：按钮、进度条、生命红心、波次文字、暂停按钮
- **风格**：圆角矩形 + 清晰图标 + 半透明背景
- **Ludo.ai 参数**：`image_type=ui_asset`

---

## 5. 技术规格与导出要求

- **文件格式**：PNG（带透明通道）
- **分辨率**：角色/道具基础 64x64 ~ 256x256；背景根据需要
- **Spritesheet 规范**：
  - 推荐使用 TexturePacker 或类似工具打包
  - 保持统一 padding（2-4px）
  - 动画方向统一（通常从左到右或从上到下）
- **命名规范**：
  - `hero_idle.png`
  - `enemy_walk_24frames.png`
  - `tree_variant_01.png`
  - `background_grass_path.png`
- **优化**：生成后检查边缘是否干净；使用 Ludo 的 `crop` 参数去除多余透明区域

---

## 6. 一致性规则（Consistency Rules）—— 最高优先级

1. **风格锁定**：所有资产必须使用相同的 `cute cartoon` + `clean black outlines` + `soft shading`。
2. **参考图策略**（强烈推荐）：
   - 先生成 1-2 张核心资产（英雄 + 敌人 + 主树）。
   - 后续所有生成使用 `generateWithStyle` 并传入参考图 URL/base64。
3. **颜色一致**：严格遵守第 2 节调色板。
4. **线条粗细**：所有轮廓线保持相同粗细（视觉上约 2-4px 在 128px 尺寸下）。
5. **阴影方向**：统一光源方向（通常左上或正上方）。
6. **表情与比例**：角色大头小身，表情夸张但可爱。
7. **禁止事项**：
   - 不要混入写实、像素、赛博朋克等其他风格。
   - 不要生成过于复杂的纹理或过多细节。
   - 不要改变视角（除非明确要求新视角）。

---

## 7. Ludo.ai / AI 生成提示词模板

### 基础模板（每次生成时必须包含）
```
[具体描述], cute cartoon 2D mobile game asset, angled top-down view, clean black outlines, flat colors with soft shading, vibrant fantasy style, high quality, consistent with Warcraft Defender art style
```

### 进阶模板（带参考一致性）
```
Generate in exact same cute cartoon style as the reference image: [参考图描述或URL], [新资产具体描述], angled top-down fantasy defense game, clean black outlines, vibrant colors, mobile game asset
```

### 动画提示模板
```
[角色描述], [动作描述 e.g. walking cycle from right to left, seamless loop], cute cartoon style, 24 frames, clean motion, fantasy defense game spritesheet
```

**推荐 Ludo.ai 参数组合**：
- `art_style`: "cute cartoon" 或 "Western Cartoon" 或 "stylized cartoon"
- `perspective`: "angled top-down" 或 "top-down"
- `image_type`: 根据资产类型选择（background / sprite / asset / ui_asset）
- `n`: 4~8（多生成选优）

---

## 8. 使用流程建议（与 AI Agent 配合）

1. **首次生成**：用本 DESIGN.md 作为系统提示，批量生成核心资产（英雄、敌人、主背景、树木、围栏、平台）。
2. **一致性迭代**：挑选最佳核心资产 → 用 `generateWithStyle` 生成所有变体和动画。
3. **动画阶段**：用 `generatePose` → `animateSprite`。
4. **微调**：用 `editImage` 修复小问题。
5. **下载与管理**：**立即下载所有生成结果**（URL 7 天后过期），按命名规范保存到 `assets/` 文件夹。
6. **引擎导入**：打包 spritesheet → 导入 Godot/Unity/Cocos → 测试动画流畅度与颜色。

---

## 9. 示例资产清单（MVP 阶段推荐优先级）

**Phase 1（核心 Demo）**：
- 1 张主背景（草地+路径）
- 6 个树木变体
- 1 套木栅栏 + 大门
- 1 个英雄平台
- 1 个英雄静态图 + 行走 + 攻击动画
- 1 个敌人静态图 + 行走 + 攻击 + 死亡动画
- 基础 UI（生命红心、波次条、按钮）

**Phase 2**：
- 更多敌人类型
- 升级后平台变体
- VFX（箭矢、攻击特效）
- 不同关卡背景（夜晚、雪地等，但保持相同卡通风格）

---

## 10. 备注与更新记录

- 本文档为**活文档**，每次风格微调后请更新。
- 所有生成素材必须通过本规范审核一致性。
- 如需生成新类型资产（例如 3D 模型、视频），请先在本规范中补充对应章节。

**维护者**：AI Agent + 开发者  
**联系方式**：（待补充）

---

**使用方法**：
在每次调用 Ludo.ai MCP / API 时，将本 DESIGN.md 的关键部分（尤其是第 1、2、6、7 节）作为系统提示或附加说明，即可大幅提升生成素材的一致性和质量。
