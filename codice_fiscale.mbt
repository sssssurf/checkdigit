// Codice Fiscale, the Italian tax code. Sixteen characters: six letters from
// the name, four characters of birth date, four of birthplace, and a final
// check letter called the CIN. The CIN is computed over the first fifteen with
// two different value tables — one for the odd positions and one for the even —
// summed and taken modulo 26.

///|
/// Values for the odd positions, the first, third and so on. The table is not a
/// pattern: digits and the first ten letters share one sequence, and the rest
/// are scattered, so it has to be listed.
let cf_odd : Array[Int] = [
  1, 0, 5, 7, 9, 13, 15, 17, 19, 21, 1, 0, 5, 7, 9, 13, 15, 17, 19, 21, 2, 4, 18,
  20, 11, 3, 6, 8, 12, 14, 16, 10, 22, 25, 24, 23,
]

///|
/// Values for the even positions, the second, fourth and so on: a digit is
/// worth its own value and a letter is worth its position in the alphabet.
let cf_even : Array[Int] = [
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,
  15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
]

///|
/// The letters a CIN can be, indexed by the remainder.
let cf_letters : Array[Char] = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
  'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
]

///|
/// The letters that mark the month of birth. There is no code for every letter
/// of the alphabet; the sequence skips over the ones that would spell words.
let cf_month_codes : Array[Char] = [
  'A', 'B', 'C', 'D', 'E', 'H', 'L', 'M', 'P', 'R', 'S', 'T',
]

///|
/// The ten letters an omocodia code substitutes for digits, used when two
/// people would otherwise share a code.
let cf_omocodia_letters : Array[Char] = [
  'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V',
]

///|
/// The table index of a character: digits take their own value and letters take
/// 10..35, so the two tables can be indexed the same way.
fn cf_index(c : Char) -> Int? {
  let u = upper_ascii(c)
  if is_digit(u) {
    Some(u.to_int() - '0'.to_int())
  } else if is_alpha(u) {
    Some(10 + (u.to_int() - 'A'.to_int()))
  } else {
    None
  }
}

///|
/// True for a character that may stand where a digit is expected: a digit, or
/// one of the omocodia letters.
fn cf_numeric_char(c : Char) -> Bool {
  let u = upper_ascii(c)
  if is_digit(u) {
    return true
  }
  for l in cf_omocodia_letters {
    if u == l {
      return true
    }
  }
  false
}

///|
/// True for one of the twelve month codes.
fn cf_month_char(c : Char) -> Bool {
  let u = upper_ascii(c)
  for m in cf_month_codes {
    if u == m {
      return true
    }
  }
  false
}

///|
/// The CIN implied by the first fifteen characters of a codice fiscale.
fn cf_expected(cs : Array[Char]) -> Char? {
  let mut sum = 0
  for i = 0; i < 15; i = i + 1 {
    let v = match cf_index(cs[i]) {
      None => return None
      Some(v) => v
    }
    // The first character counts as position one, which is an odd position.
    if i % 2 == 0 {
      sum = sum + cf_odd[v]
    } else {
      sum = sum + cf_even[v]
    }
  }
  Some(cf_letters[sum % 26])
}

///|
/// The check letter that belongs after the first 15 characters of a codice
/// fiscale.
pub fn cf_check_char(first15 : String) -> String? {
  let cs = chars_of(first15)
  if cs.length() != 15 {
    return None
  }
  match cf_expected(cs) {
    None => None
    Some(c) => Some(char_str(c))
  }
}

///|
/// Validate a 16-character codice fiscale, including the layout the code is
/// required to follow: six letters, two numeric characters, a month letter, two
/// numeric characters, a letter, three numeric characters and the check letter.
/// Lowercase input is accepted.
pub fn cf_valid(s : String) -> Bool {
  let cs = chars_of(s)
  if cs.length() != 16 {
    return false
  }
  for i = 0; i < 6; i = i + 1 {
    if !is_alpha(upper_ascii(cs[i])) {
      return false
    }
  }
  if !cf_numeric_char(cs[6]) || !cf_numeric_char(cs[7]) {
    return false
  }
  if !cf_month_char(cs[8]) {
    return false
  }
  if !cf_numeric_char(cs[9]) || !cf_numeric_char(cs[10]) {
    return false
  }
  if !is_alpha(upper_ascii(cs[11])) {
    return false
  }
  for i = 12; i < 15; i = i + 1 {
    if !cf_numeric_char(cs[i]) {
      return false
    }
  }
  if !is_alpha(upper_ascii(cs[15])) {
    return false
  }
  match cf_expected(cs) {
    None => false
    Some(expected) => upper_ascii(cs[15]) == expected
  }
}
