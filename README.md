# checkdigit

Check-digit algorithms and identifier validation for MoonBit.

[![license](https://img.shields.io/badge/license-Apache--2.0-blue)](LICENSE)
[![mooncakes](https://img.shields.io/badge/mooncakes.io-checkdigit-8a2be2)](https://mooncakes.io/docs/sssssurf/checkdigit)

`checkdigit` implements the three check-digit algorithms used by most real-world
numbering schemes, and builds the identifier formats on top of them: payment
cards (ISO/IEC 7812), IBAN bank accounts (ISO 13616), and IMEI device numbers
(3GPP TS 23.003).

```moonbit
fn main {
  // 7992739871 -> check digit 3
  println(luhn_check_digit("7992739871")) // Some(3)
  println(luhn_valid("79927398713"))      // true

  // Brand detection and full card check
  println(detect_brand("378282246310005")) // amex
  println(card_valid("378282246310005"))   // true

  // IBAN accepts spaces and lowercase
  println(iban_valid("gb82 west 1234 5698 7654 32")) // true
  println(iban_format("GB82WEST12345698765432"))     // Some("GB82 WEST 1234 5698 7654 32")
}
```

## What it covers

| Area | Functions |
| --- | --- |
| Luhn (mod 10) | `luhn_valid`, `luhn_check_digit` |
| Verhoeff (dihedral group D5) | `verhoeff_valid`, `verhoeff_check_digit` |
| Damm (anti-symmetric quasigroup) | `damm_valid`, `damm_check_digit` |
| Payment cards | `card_valid`, `detect_brand`, `card_format`, `CardBrand` |
| IBAN | `iban_valid`, `iban_country`, `iban_bban`, `iban_format`, `iban_normalize`, `iban_expected_length`, `iban_check_digits`, `iban_assemble` |
| IMEI | `imei_valid`, `imei_check_digit`, `imei_tac`, `imei_serial` |

All validators are total: they take a `String` and return `Bool`, or return
`None` when a value cannot be computed. No exceptions, no panics on bad input.

### Algorithms

- **Luhn** catches any single-digit error and most adjacent transpositions. Used
  by payment cards, IMEI, and many national identifiers.
- **Verhoeff** catches all single-digit errors and *all* adjacent
  transpositions, using a multiplication table over the dihedral group `D5`.
- **Damm** also catches all single-digit errors and all adjacent transpositions,
  but needs a single table lookup per digit instead of a position-dependent
  permutation.

### Identifiers

- **Payment cards** — brand detection by issuer identification number, then the
  length rules for that brand, then Luhn. Brands: Visa, Mastercard, American
  Express, Discover, JCB, Diners Club, UnionPay, Maestro. Overlapping issuer
  ranges are resolved by testing the most specific range first (Discover's
  `622126`–`622925` sits inside UnionPay's `62`).
- **IBAN** — country code, registered length for that country (75 countries),
  then the mod-97-10 check. Input is normalised, so spaces and lowercase are
  accepted. Bank account numbers can also be *generated*: `iban_check_digits`
  computes the two check digits for a country code plus BBAN, and
  `iban_assemble` returns the complete IBAN.
- **IMEI** — 15 digits with a Luhn check digit, plus `TAC` (first 8 digits) and
  serial number (digits 9–14) extraction.

## Installation

```bash
moon add sssssurf/checkdigit
```

## Command line

The repository also ships a small CLI for trying the validators out:

```bash
moon run cmd/main -- card 378282246310005
moon run cmd/main -- iban "gb82 west 1234 5698 7654 32"
moon run cmd/main -- imei 490154203237518
moon run cmd/main -- luhn 7992739871
moon run cmd/main -- verhoeff 236
moon run cmd/main -- damm 572
```

```text
$ moon run cmd/main -- imei 490154203237518
imei: 490154203237518
tac: 49015420
serial: 323751
check digit: 8
status: valid
```

## 与现有库的关系（互补边界）

生态里已经有一批**通用校验 / schema 库**，它们与本库处理的层次不同，因此是互补而非重叠：

| 已有库 | 它解决的问题 | 与本库的边界 |
| --- | --- | --- |
| `Betterlol/moon_zod`、`cosgammmmma/moonschema`、`mizchi/jsonschema` | JSON / 数据结构的 schema 校验：字段类型、必填、`email` / `uuid` / `url` 等格式约束 | 它们校验**数据的形状与格式**，不做任何算术校验位运算。本库只做**数字标识符的校验位算法**，不解析 JSON，也不定义 schema。 |
| `ryota0624/moovalid` | 通用校验组合子（`Validated`、错误累积、`in_range` 等） | 它提供**校验框架**；本库提供**具体领域算法**。本库不提供错误累积或组合子 API。 |
| `ZJH-666-ZJH/moonmrz` | ICAO 9303 机读区（护照 / 签证 MRZ）的 7-3-1 校验位 | 唯一的交集是"校验位"这个概念。它面向**旅行证件 MRZ 文本**，使用 ICAO 9303 的 7-3-1 加权方案；本库面向**支付卡 / 银行账号 / 设备号**，使用 Luhn、Verhoeff、Damm 与 mod-97。两者的算法、输入格式、应用领域均不同。 |

在 mooncakes.io 上以 `luhn`、`iban`、`imei` 检索，目前**没有任何**模块命中；本库填补的是这一块空白。

## Testing

```bash
moon test
```

29 tests cover the three algorithms against published reference vectors, the
issuer-range overlap boundaries, IBAN's published examples, and malformed input.

## References

- ISO/IEC 7812 — Identification cards, issuer identification numbers
- ISO 13616 — International Bank Account Number (IBAN), mod-97-10
- 3GPP TS 23.003 — Numbering, addressing and identification (IMEI)
- H. P. Damm, *Totally anti-symmetric quasigroups for all orders n ≠ 2 mod 4*
- J. Verhoeff, *Error detecting decimal codes*

## License

Apache-2.0. See [LICENSE](LICENSE).
