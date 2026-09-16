// Vehicle Identification Numbers, ISO 3779. A VIN is 17 characters drawn from
// digits and letters, excluding I, O and Q so they cannot be confused with 1
// and 0. The ninth character is a check character computed modulo 11, which
// may be the letter X.

///|
/// Transliteration values fixed by ISO 3779, indexed by letter. I, O and Q are
/// not valid VIN characters, so their entries are marked -1 and rejected.
let vin_letter_values : Array[Int] = [
  1, 2, 3, 4, 5, 6, 7, 8, -1, 1, 2, 3, 4, 5, -1, 7, -1, 9, 2, 3, 4, 5, 6, 7, 8, 9,
]

///|
/// Positional weights. The ninth weight is zero, which is what lets the check
/// character sit in the middle of the number without affecting the sum.
let vin_weights : Array[Int] = [
  8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2,
]

///|
/// Check characters indexed by the weighted sum's remainder.
let vin_check_chars : Array[Char] = [
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'X',
]

///|
/// Transliterated value of one VIN character, or None when it may not appear.
fn vin_value(c : Char) -> Int? {
  let u = upper_ascii(c)
  if is_digit(u) {
    Some(u.to_int() - '0'.to_int())
  } else if is_alpha(u) {
    let v = vin_letter_values[u.to_int() - 'A'.to_int()]
    if v < 0 {
      None
    } else {
      Some(v)
    }
  } else {
    None
  }
}

///|
/// The check character implied by the other sixteen positions.
fn vin_expected(cs : Array[Char]) -> Char? {
  let mut sum = 0
  for i = 0; i < 17; i = i + 1 {
    let v = match vin_value(cs[i]) {
      None => return None
      Some(v) => v
    }
    sum = sum + v * vin_weights[i]
  }
  Some(vin_check_chars[sum % 11])
}

///|
/// The check character that belongs in position nine, as a string ("0".."9" or
/// "X").
pub fn vin_check_char(first17 : String) -> String? {
  let cs = chars_of(first17)
  if cs.length() != 17 {
    return None
  }
  match vin_expected(cs) {
    None => None
    Some(c) => Some(char_str(c))
  }
}

///|
/// Validate a 17-character VIN, including its check character. Lowercase input
/// is accepted.
pub fn vin_valid(s : String) -> Bool {
  let cs = chars_of(s)
  if cs.length() != 17 {
    return false
  }
  match vin_expected(cs) {
    None => false
    Some(expected) => upper_ascii(cs[8]) == expected
  }
}

///|
/// The World Manufacturer Identifier: the first three characters, or None when
/// the VIN is not valid.
pub fn vin_wmi(s : String) -> String? {
  if !vin_valid(s) {
    return None
  }
  substring(s, 0, 3)
}

///|
/// The Vehicle Identifier Section: the last eight characters, or None when the
/// VIN is not valid.
pub fn vin_vis(s : String) -> String? {
  if !vin_valid(s) {
    return None
  }
  substring(s, 9, 8)
}
