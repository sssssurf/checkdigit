// Chinese resident identity card numbers, GB 11643-1999. An 18-character
// number is six digits of administrative division, eight digits of birth date,
// three digits of sequence, and a check character computed with the ISO 7064
// MOD 11-2 scheme. The check character is a digit or the letter X.

///|
/// Positional weights from GB 11643. Read right to left they are 2^k mod 11.
let cn_id_weights : Array[Int] = [
  7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2,
]

///|
/// Check characters indexed by the weighted sum's remainder, in the order the
/// standard fixes: remainder 2 always yields X.
let cn_id_codes : Array[Char] = [
  '1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2',
]

///|
/// The check character for the first 17 characters, or None when any of them
/// is not a digit.
fn cn_id_expected(cs : Array[Char]) -> Char? {
  let mut sum = 0
  for i = 0; i < 17; i = i + 1 {
    if !is_digit(cs[i]) {
      return None
    }
    sum = sum + (cs[i].to_int() - '0'.to_int()) * cn_id_weights[i]
  }
  Some(cn_id_codes[sum % 11])
}

///|
/// Shallow plausibility check on the eight birth-date digits. Impossible months
/// and day numbers are rejected, but month lengths and leap years are not
/// modelled, so 31 February is accepted.
fn cn_id_date_plausible(cs : Array[Char]) -> Bool {
  let mut v = 0
  for i = 6; i < 14; i = i + 1 {
    if !is_digit(cs[i]) {
      return false
    }
    v = v * 10 + (cs[i].to_int() - '0'.to_int())
  }
  let year = v / 10000
  let month = v / 100 % 100
  let day = v % 100
  year >= 1800 &&
  year <= 2199 &&
  month >= 1 &&
  month <= 12 &&
  day >= 1 &&
  day <= 31
}

///|
/// The check character that should follow the first 17 digits of an identity
/// card number, as a string ("0".."9" or "X").
pub fn cn_id_check_char(first17 : String) -> String? {
  let cs = chars_of(first17)
  if cs.length() != 17 {
    return None
  }
  match cn_id_expected(cs) {
    None => None
    Some(c) => Some(char_str(c))
  }
}

///|
/// Validate an 18-character resident identity card number. Lowercase "x" is
/// accepted for the check character.
pub fn cn_id_valid(s : String) -> Bool {
  let cs = chars_of(s)
  if cs.length() != 18 {
    return false
  }
  if !cn_id_date_plausible(cs) {
    return false
  }
  match cn_id_expected(cs) {
    None => false
    Some(expected) => upper_ascii(cs[17]) == expected
  }
}

///|
/// The six-digit administrative division code, or None when the number is not
/// valid.
pub fn cn_id_region(s : String) -> String? {
  if !cn_id_valid(s) {
    return None
  }
  substring(s, 0, 6)
}

///|
/// The eight birth-date digits as YYYYMMDD, or None when the number is not
/// valid.
pub fn cn_id_birthdate(s : String) -> String? {
  if !cn_id_valid(s) {
    return None
  }
  substring(s, 6, 8)
}
