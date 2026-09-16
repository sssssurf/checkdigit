// Unified Social Credit Identifier, GB 32100. Eighteen characters: one of
// registration authority, one of entity category, six of administrative
// division, nine of organisation code, and a check character. The code set is
// the digits plus the letters A-Z minus I, O, S, V and Z, giving 31 characters
// — one for each residue of the weighted sum.

///|
/// Positional weights. Character i, counting from one, carries 3^(i-1) mod 31,
/// which spreads a single wrong character across the whole sum rather than
/// shifting it by a constant.
let uscc_weights : Array[Int] = [
  1, 3, 9, 27, 19, 26, 16, 17, 20, 29, 25, 13, 8, 24, 10, 30, 28,
]

///|
/// The 31-character code set in value order. The five letters left out are
/// those that read as another character: I as 1, O as 0, and S, V, Z as 5, U,
/// 2 in handwriting.
let uscc_chars : Array[Char] = [
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F',
  'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'T', 'U', 'W', 'X', 'Y',
]

///|
/// Numeric value of one character, or None when it is outside the code set.
/// Indexed by ASCII offset, so digits sit at 0..9 and letters at 10..35; the
/// five excluded letters hold -1.
let uscc_values : Array[Int] = [
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, -1, 18, 19, 20, 21,
  22, -1, 23, 24, 25, -1, 26, 27, -1, 28, 29, 30, -1,
]

///|
/// Numeric value of one character, folding lowercase first.
fn uscc_value(c : Char) -> Int? {
  let u = upper_ascii(c)
  let idx = if is_digit(u) {
    u.to_int() - '0'.to_int()
  } else if is_alpha(u) {
    10 + (u.to_int() - 'A'.to_int())
  } else {
    return None
  }
  let v = uscc_values[idx]
  if v < 0 {
    None
  } else {
    Some(v)
  }
}

///|
/// The check character implied by the first seventeen characters.
fn uscc_expected(cs : Array[Char]) -> Char? {
  let mut sum = 0
  for i = 0; i < 17; i = i + 1 {
    let v = match uscc_value(cs[i]) {
      None => return None
      Some(v) => v
    }
    sum = sum + v * uscc_weights[i]
  }
  let mut r = 31 - sum % 31
  if r == 31 {
    r = 0
  }
  Some(uscc_chars[r])
}

///|
/// The check character that should follow the first 17 characters of a unified
/// social credit identifier.
pub fn uscc_check_char(first17 : String) -> String? {
  let cs = chars_of(first17)
  if cs.length() != 17 {
    return None
  }
  match uscc_expected(cs) {
    None => None
    Some(c) => Some(char_str(c))
  }
}

///|
/// Validate an 18-character unified social credit identifier. Lowercase input
/// is accepted.
pub fn uscc_valid(s : String) -> Bool {
  let cs = chars_of(s)
  if cs.length() != 18 {
    return false
  }
  match uscc_expected(cs) {
    None => false
    Some(expected) => upper_ascii(cs[17]) == expected
  }
}

///|
/// The six-character administrative division code, characters three to eight,
/// or None when the identifier is not valid.
pub fn uscc_division(s : String) -> String? {
  if !uscc_valid(s) {
    return None
  }
  substring(s, 2, 6)
}
