// ISIN (International Securities Identification Number), ISO 6166. Twelve
// characters: a two-letter country code, nine alphanumeric characters naming
// the security, and one check digit. The check digit is a Luhn digit computed
// over the identifier after every letter has been expanded to its two-digit
// numeric value.

///|
/// Expand an alphanumeric identifier to its digit string: letters become
/// 10..35, digits stay as they are. Returns None on any other character.
fn isin_expanded(s : String) -> String? {
  let buf = StringBuilder()
  for c in s {
    match alnum_value(c) {
      None => return None
      Some(v) => buf.write_string(v.to_string())
    }
  }
  Some(buf.to_string())
}

///|
/// Validate a 12-character ISIN. Lowercase input is accepted.
pub fn isin_valid(s : String) -> Bool {
  let cs = chars_of(s)
  if cs.length() != 12 {
    return false
  }
  if !is_alpha(upper_ascii(cs[0])) || !is_alpha(upper_ascii(cs[1])) {
    return false
  }
  if !alnum_only(s) {
    return false
  }
  match isin_expanded(s) {
    None => false
    Some(digits) => luhn_valid(digits)
  }
}

///|
/// The Luhn check digit implied by the first eleven characters of an ISIN.
pub fn isin_check_digit(first11 : String) -> Int? {
  let cs = chars_of(first11)
  if cs.length() != 11 || !alnum_only(first11) {
    return None
  }
  match isin_expanded(first11) {
    None => None
    Some(digits) => luhn_check_digit(digits)
  }
}

///|
/// The two-letter country code of an ISIN, or None when it is malformed.
pub fn isin_country(s : String) -> String? {
  let cs = chars_of(s)
  if cs.length() < 2 {
    return None
  }
  if !is_alpha(upper_ascii(cs[0])) || !is_alpha(upper_ascii(cs[1])) {
    return None
  }
  Some(char_str(upper_ascii(cs[0])) + char_str(upper_ascii(cs[1])))
}
