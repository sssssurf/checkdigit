# Changelog

本文件按时间倒序记录每个版本的实质改动,用于对应验收标准中「工作有效:已有项目必须包含
本期完成的实质新增工作」一条。

## Unreleased — 2026-09-18

本轮加固可复现性:文档里记录的命令输出不再依赖人工维护,而是被自动校验。

### 新增

- **`scripts/check-docs.mjs`**:文档一致性校验器。实际执行文档中记录的命令,逐字比对
  `cmd/demo` 的 56 行输出、README 里的 CLI 输出块、两份 README 声称的测试数,并确认
  README 命令列表里的 16 条命令都能成功退出。**该检查会失败**:改动任意一行文档输出后
  运行,它会指出具体行以及文档与实际的差异。
  - 输出捕获走 shell 重定向到临时文件,而非管道 stdio —— 后者在开发沙箱中会触发 EPERM。
    该写法在 Windows 与 Linux 上都可用。
- **CI**:新增 "Documentation matches real output" 步骤,文档漂移会让构建变红。

### 变更

- `README.md` / `README.mbt.md` / `docs/reproducible-demo.md`:记录这条校验命令及其用法。

## Unreleased — 2026-09-17

本轮针对 2026 MoonBit 九月黑客松「验收标准」逐条加固,重点是测试质量、文档与可复现性。

### 新增

- **`cmd/demo`**:覆盖全部 13 种标识符的端到端可运行示例。输出全部由库在运行时产生,
  最后一节用五种垃圾输入演示"全函数、不 panic"承诺。对应验收条目「能够运行」。
- **`robustness_test.mbt`**:对抗性测试矩阵。23 种恶意输入(空串、纯空白、全角数字、
  阿拉伯-印度数字、超长串、内嵌空格、尾部 NUL 等)横穿 50 个公开函数调用点。
  用可执行断言固定"非法输入返回 `false` 或 `None`、绝不 panic"这条公开承诺。
- **`docs/reproducible-demo.md`**:可复现演示说明。列出环境、四条验证命令及其期望输出。
- **`docs/development-retrospective.md`**:开发回顾。十项关键架构决策及其代价、
  AI 工具在开发中的分工、标准与相邻开源项目引用、四条已知限制。

### 变更

- **`checkdigit_test.mbt`**:新增 5 个 `cn_id` 边界测试。测试向量由一个独立实现交叉算出,
  并对公开标准样例 `11010519491231002X` 自校验后才写入,避免用被测代码生成自己的期望值。
  覆盖:身体位篡改、错误长度与非数字字符、出生年上下界、已被文档记录的
  "31 February 被接受"限制、校验位生成器与校验器的往返一致性。
- **`.github/workflows/ci.yml`**:新增 `wasm` / `wasm-gc` / `native` 三目标构建矩阵与
  `moon fmt --check`。此前 CI 只构建默认目标,导致"三目标可编译"这一声明无法被自动验证。
- **`README.md` / `README.mbt.md`**:测试数由 77 更正为 88(此前已与仓库实际不符),
  新增 Development 一节指向开发回顾文档。

### 影响

- 测试用例数:77 → 88,全部通过。
- `moon check`、`moon fmt --check`、`moon test`、`moon build --target wasm|wasm-gc` 全部通过。
- 公开 API 未变,无破坏性改动。

## 0.3.0 — 2026-09-16

- `feat`:codice fiscale 校验(CIN 校验字母、奇偶双表、月份码与 omocodia 结构检查)。
- `feat`:BSN 荷兰 11 检验,含八位补零形式与校验位反推。
- `feat`:CPF / CNPJ 巴西双 mod 11 校验,含全同数字排除与格式化输出。
- `feat`:统一社会信用代码 GB 32100(31 字符码集、模 31 加权、行政区划提取)。
- `feat`:五个新校验器的 CLI 子命令。
- `test`:五个新校验器的参考向量。
- `docs`:记录新标识符并扩充边界说明。

## 0.2.0 — 2026-09-15

- `feat`:LEI 校验(ISO 17442)、ISIN(ISO 6166)、VIN(ISO 3779)、Aadhaar(Verhoeff)、
  中国居民身份证号(GB 11643)。
- `test`:参考向量与内部辅助函数白盒测试。
- `refactor`:共享数值辅助函数从 `card.mbt` 移入 `util.mbt`。

## 0.1.0 — 2026-09-12

- `feat`:Luhn(mod 10)、Verhoeff(D5 二面体群)、Damm(反对称拟群)三个算法模块。
- `feat`:支付卡卡组织识别、校验与分组显示;IBAN 校验、解析与校验位生成;IMEI 校验与
  TAC/序列号提取。
- `feat`:六个校验器的命令行前端。
- `test`:黑盒与白盒两层测试。
- `chore`:模块骨架、CI、Apache-2.0 许可证、README。
