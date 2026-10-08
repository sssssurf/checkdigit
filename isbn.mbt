// Bibliographic numbers: ISBN-10, ISBN-13 and ISSN. ISBN-10 carries a mod-11
// check character that may be X (ten); ISBN-13 is an EAN-13 restricted to the
// 978 and 979 bookland prefixes, so it reuses the GS1 check digit; ISSN is an
// eight-character serial number with its own mod-11 check character.

///|
/// The check character for the first nine digits of an ISBN-10. It is a digit,
/// or 'X' for the value ten. Weights run 10 down to 2. Returns None unless all
/// nine characters are digits.
pub fn isbn10_check_char(first9 : String) -> Char? {
  let cs = chars_of(first9)
  if cs.length() != 9 {
    return None
  }
  let mut sum = 0
  for i = 0; i < 9; i = i + 1 {
    let c = cs[i]
    if !is_digit(c) {
      return None
    }
    sum = sum + (c.to_int() - '0'.to_int()) * (10 - i)
  }
  let v = (11 - sum % 11) % 11
  Some(if v == 10 { 'X' } else { digit_char(v) })
}

///|
/// Validate a ten-character ISBN-10. The last character may be 'X'; a lowercase
/// 'x' is accepted.
pub fn isbn10_valid(s : String) -> Bool {
  let cs = chars_of(s)
  if cs.length() != 10 {
    return false
  }
  for i = 0; i < 9; i = i + 1 {
    if !is_digit(cs[i]) {
      return false
    }
  }
  let body = match substring(s, 0, 9) {
    None => return false
    Some(b) => b
  }
  match isbn10_check_char(body) {
    None => false
    Some(c) => c == upper_ascii(cs[9])
  }
}

///|
/// The check digit of the thirteen-digit ISBN form for a twelve-digit payload.
/// The payload must begin with the 978 or 979 bookland prefix, so an arbitrary
/// EAN-13 is not accepted here. Returns None otherwise.
pub fn isbn13_check_digit(first12 : String) -> Int? {
  let cs = chars_of(first12)
  if cs.length() != 12 {
    return None
  }
  let prefix = match substring(first12, 0, 3) {
    None => return None
    Some(p) => p
  }
  if prefix != "978" && prefix != "979" {
    return None
  }
  gtin_check_digit(first12)
}

///|
/// Validate a thirteen-character ISBN-13: an EAN-13 whose prefix is 978 or 979.
pub fn isbn13_valid(s : String) -> Bool {
  let cs = chars_of(s)
  if cs.length() != 13 {
    return false
  }
  let body = match substring(s, 0, 12) {
    None => return false
    Some(b) => b
  }
  match isbn13_check_digit(body) {
    None => false
    Some(cd) => is_digit(cs[12]) && cd == (cs[12].to_int() - '0'.to_int())
  }
}

///|
/// Convert a ten-character ISBN-10 to its thirteen-digit ISBN-13 form: prepend
/// 978 to the nine data digits and recompute the check digit. Returns None when
/// the input is not a well-formed ISBN-10.
pub fn isbn10_to_isbn13(s : String) -> String? {
  if !isbn10_valid(s) {
    return None
  }
  let body = match substring(s, 0, 9) {
    None => return None
    Some(b) => b
  }
  let payload = "978" + body
  match gtin_check_digit(payload) {
    None => None
    Some(cd) => Some(payload + char_str(digit_char(cd)))
  }
}

///|
/// The check character for the first seven digits of an ISSN. It is a digit or
/// 'X'. Weights run 8 down to 2. Returns None unless all seven are digits.
pub fn issn_check_char(first7 : String) -> Char? {
  let cs = chars_of(first7)
  if cs.length() != 7 {
    return None
  }
  let mut sum = 0
  for i = 0; i < 7; i = i + 1 {
    let c = cs[i]
    if !is_digit(c) {
      return None
    }
    sum = sum + (c.to_int() - '0'.to_int()) * (8 - i)
  }
  let v = (11 - sum % 11) % 11
  Some(if v == 10 { 'X' } else { digit_char(v) })
}

///|
/// Validate an eight-character ISSN. The last character may be 'X'; a lowercase
/// 'x' is accepted.
pub fn issn_valid(s : String) -> Bool {
  let cs = chars_of(s)
  if cs.length() != 8 {
    return false
  }
  for i = 0; i < 7; i = i + 1 {
    if !is_digit(cs[i]) {
      return false
    }
  }
  let body = match substring(s, 0, 7) {
    None => return false
    Some(b) => b
  }
  match issn_check_char(body) {
    None => false
    Some(c) => c == upper_ascii(cs[7])
  }
}
