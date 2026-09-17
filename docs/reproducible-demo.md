# 可复现演示

本文是验收材料中的"可复现的演示说明"。所有命令都在仓库根目录执行,输出为实际运行结果。

## 环境

| 项 | 值 |
|---|---|
| MoonBit 工具链 | `moon 0.1.20260608 (60bc8c3 2026-06-08)` |
| 平台 | Windows 10.0.26200 / x86_64 |
| 外部依赖 | 无(`moon.mod` 无 `deps` 段) |

检查工具链版本:

```bash
moon version
```

## 一、跑测试

```bash
moon test
```

期望输出(末行):

```text
Total tests: 88, passed: 88, failed: 0.
```

测试分三层:

| 文件 | 层次 | 内容 |
|---|---|---|
| `checkdigit_wbtest.mbt` | 白盒 | 直接测试包内私有辅助函数与各张权重表 |
| `checkdigit_test.mbt` | 黑盒 | 只调用 `pub fn`,用公开标准样例作参考向量 |
| `robustness_test.mbt` | 对抗 | 23 种恶意输入横穿 50 个公开函数调用点 |

`robustness_test.mbt` 的意义是把"全函数、不 panic"这条承诺变成可执行的断言:空串、纯空白、
全角数字、阿拉伯-印度数字、超长串、内嵌空格、尾部 NUL 等输入如果让任何函数 abort,
测试就会失败。

## 二、跑可运行示例

```bash
moon run cmd/demo
```

这是覆盖全部 13 种标识符的端到端演示。**输出全部由库在运行时产生,没有任何硬编码**,
所以校验逻辑一旦回归,这段输出就会跟着变。

完整输出:

```text
checkdigit — validator tour
every line below is produced by the library at run time

== algorithms (payload only, no identifier semantics) ==
luhn_check_digit(7992739871): 3
luhn_valid(79927398713): valid
luhn_valid(79927398710): invalid
verhoeff_check_digit(236): 3
verhoeff_valid(2363): valid
damm_check_digit(572): 4
damm_valid(5724): valid

== payment cards ==
detect_brand(4111111111111111): visa
detect_brand(378282246310005): amex
card_valid(378282246310005): valid
card_format(378282246310005): 3782 8224 6310 005

== IBAN ==
iban_valid(GB82 WEST 1234 5698 7654 32): valid
iban_country: GB
iban_bban: WEST12345698765432
iban_format: GB82 WEST 1234 5698 7654 32
iban_check_digits(GB, WEST...): 82
iban_assemble(GB, WEST...): GB82WEST12345698765432
iban_expected_length(GB): 22

== device and identity numbers ==
imei_tac(490154203237518): 49015420
imei_serial(490154203237518): 323751
imei_check_digit(49015420323751): 8
cn_id_valid(11010519491231002X): valid
cn_id_region: 110105
cn_id_birthdate: 19491231
cn_id_check_char(11010519491231002): X
aadhaar_valid(234123412346): valid

== securities and legal entities ==
vin_valid(1M8GDM9AXKP042788): valid
vin_wmi: 1M8
vin_vis: KP042788
isin_valid(US0378331005): valid
isin_country(US0378331005): US
lei_valid(529900T8BM49AURSDO55): valid
lei_lou(529900T8BM49AURSDO55): 5299

== jurisdiction-specific identifiers ==
uscc_valid(91350100M000100Y43): valid
uscc_division(91350100M000100Y43): 350100
cpf_valid(11144477735): valid
cpf_format(11144477735): 111.444.777-35
cnpj_valid(11222333000181): valid
cnpj_format(11222333000181): 11.222.333/0001-81
bsn_valid(111222333): valid
cf_valid(RSSMRA85T10A562S): valid

== the totality promise: bad input never panics ==
  [] -> luhn=false cnid=false iban=false
  [ ] -> luhn=false cnid=false iban=false
  [not-a-number] -> luhn=false cnid=false iban=false
  [1234567890] -> luhn=false cnid=false iban=false
  [9999999999999999999999] -> luhn=false cnid=false iban=false

done
```

最后一节就是"全函数"承诺的直观展示:五种垃圾输入进了三个校验器,全部返回 `false`,
没有任何一个中止进程。

## 三、跑命令行工具

```bash
moon run cmd/main -- card 378282246310005
moon run cmd/main -- iban "gb82 west 1234 5698 7654 32"
moon run cmd/main -- imei 490154203237518
moon run cmd/main -- lei 529900T8BM49AURSDO55
```

16 个子命令完整列表可以直接无参数运行 `moon run cmd/main` 得到:

```text
checkdigit — check digits and identifier validation for MoonBit
usage:
  checkdigit luhn     <digits>
  checkdigit verhoeff <digits>
  checkdigit damm     <digits>
  checkdigit card     <number>
  checkdigit iban     <iban>
  checkdigit imei     <imei>
  checkdigit cnid     <resident id number>
  checkdigit aadhaar  <12 digits>
  checkdigit vin      <vin>
  checkdigit isin     <isin>
  ...
```

## 四、验证三个编译目标

```bash
moon build --target wasm
moon build --target wasm-gc
moon build --target native
```

前两个目标不依赖任何系统库。`native` 目标在链接阶段需要一个 C 编译器
(`cl` / `clang` / `gcc` 之一);若本机没有,会报
`no system C compiler found`,这属于环境缺失而非代码问题。CI 在 ubuntu-latest
上提供 gcc,因此 `native` 目标在 CI 中被真实验证。

```bash
moon check      # 类型与静态检查
moon fmt --check # 格式检查
```

## 五、审批材料对应的证据

| 验收条目 | 本仓库的对应证据 |
|---|---|
| 以 MoonBit 为主要实现语言 | `moon.mod`、`*.mbt` 全部源码 |
| 仓库公开、提交连续可追踪 | GitHub 仓库与 commits / Issues / PR |
| 能够运行:README、可运行示例、必要测试 | `README.md`、`cmd/demo`、`moon test` |
| 工作有效:本期实质新增 | `CHANGELOG.md` |
| 开源合规 | `LICENSE`(Apache-2.0)、README 的 References 与相邻项目边界表 |
| 可解释 | `docs/development-retrospective.md` |
