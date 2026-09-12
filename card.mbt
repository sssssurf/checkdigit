// Payment card validation: brand detection by issuer identification number
// (IIN/BIN) ranges, then length and Luhn checks.

///|
/// Recognised card networks. `Unknown` means no issuer range matched.
pub enum CardBrand {
  Visa
  Mastercard
  Amex
  Discover
  Jcb
  DinersClub
  UnionPay
  Maestro
  Unknown
}

///|
pub impl Show for CardBrand with fn to_string(self) -> String {
  match self {
    Visa => "visa"
    Mastercard => "mastercard"
    Amex => "amex"
    Discover => "discover"
    Jcb => "jcb"
    DinersClub => "diners-club"
    UnionPay => "unionpay"
    Maestro => "maestro"
    Unknown => "unknown"
  }
}

///|
/// Read the first `n` characters as an integer. None if there are too few
/// characters or any of them is not a digit.
fn leading_int(s : String, n : Int) -> Int? {
  let chars = chars_of(s)
  if chars.length() < n {
    return None
  }
  let mut v = 0
  for i = 0; i < n; i = i + 1 {
    let c = chars[i]
    if c < '0' || c > '9' {
      return None
    }
    v = v * 10 + (c.to_int() - '0'.to_int())
  }
  Some(v)
}

///|
/// True when the first `n` digits fall in `[lo, hi]`.
fn prefix_in(s : String, n : Int, lo : Int, hi : Int) -> Bool {
  match leading_int(s, n) {
    Some(v) => v >= lo && v <= hi
    None => false
  }
}

///|
/// Number of digits, or None if the string holds anything else.
fn digit_count(s : String) -> Int? {
  match digits_of(s) {
    Some(d) => Some(d.length())
    None => None
  }
}

///|
/// Identify the card network from its issuer range. The most specific ranges
/// are tested first (Discover's 622126-622925 range overlaps UnionPay's 62).
pub fn detect_brand(s : String) -> CardBrand {
  if prefix_in(s, 2, 34, 34) || prefix_in(s, 2, 37, 37) {
    return Amex
  }
  let discover = prefix_in(s, 6, 622126, 622925) ||
    prefix_in(s, 4, 6011, 6011) ||
    prefix_in(s, 2, 65, 65) ||
    prefix_in(s, 3, 644, 649)
  if discover {
    return Discover
  }
  if prefix_in(s, 4, 3528, 3589) {
    return Jcb
  }
  let diners = prefix_in(s, 3, 300, 305) ||
    prefix_in(s, 2, 36, 36) ||
    prefix_in(s, 2, 38, 39)
  if diners {
    return DinersClub
  }
  let maestro = prefix_in(s, 4, 5018, 5018) ||
    prefix_in(s, 4, 5020, 5020) ||
    prefix_in(s, 4, 5038, 5038) ||
    prefix_in(s, 4, 5893, 5893) ||
    prefix_in(s, 4, 6304, 6304) ||
    prefix_in(s, 4, 6759, 6759) ||
    prefix_in(s, 4, 6761, 6763)
  if maestro {
    return Maestro
  }
  if prefix_in(s, 2, 51, 55) || prefix_in(s, 4, 2221, 2720) {
    return Mastercard
  }
  if prefix_in(s, 1, 4, 4) {
    return Visa
  }
  if prefix_in(s, 2, 62, 62) {
    return UnionPay
  }
  Unknown
}

///|
/// Whether `len` digits is a valid length for this brand.
fn brand_length_ok(brand : CardBrand, len : Int) -> Bool {
  match brand {
    Visa => len == 13 || len == 16 || len == 19
    Mastercard => len == 16
    Amex => len == 15
    Discover => len == 16 || len == 19
    Jcb => len >= 16 && len <= 19
    DinersClub => len == 14 || len == 16 || len == 19
    UnionPay => len >= 16 && len <= 19
    Maestro => len >= 12 && len <= 19
    Unknown => false
  }
}

///|
/// Full card check: a known brand, a valid length for that brand, and a
/// correct Luhn check digit.
pub fn card_valid(s : String) -> Bool {
  let len = match digit_count(s) {
    None => return false
    Some(n) => n
  }
  brand_length_ok(detect_brand(s), len) && luhn_valid(s)
}

///|
/// Group the digits into blocks of four for display, e.g.
/// "3782 8224 6310 005". Returns None unless every character is a digit.
pub fn card_format(s : String) -> String? {
  if digits_of(s) is None {
    return None
  }
  let buf = StringBuilder()
  let mut i = 0
  for ch in s {
    if i > 0 && i % 4 == 0 {
      buf.write_char(' ')
    }
    buf.write_char(ch)
    i = i + 1
  }
  Some(buf.to_string())
}
