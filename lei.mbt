// LEI (Legal Entity Identifier), ISO 17442. Twenty alphanumeric characters:
// four of local operating unit code, two reserved zeroes, twelve of entity
// reference, and two check digits at the end. Validation expands every letter
// to 10..35 and requires the whole identifier to be 1 modulo 97 — the same
// scheme IBAN uses.

///|
/// Validate a 20-character LEI. Lowercase input is accepted.
pub fn lei_valid(s : String) -> Bool {
  let cs = chars_of(s)
  if cs.length() != 20 || !alnum_only(s) {
    return false
  }
  match alnum_mod97(cs) {
    None => false
    Some(rem) => rem == 1
  }
}

///|
/// The two check digits that belong at the end of an LEI. Given the first
/// eighteen characters, this returns the digits that make the whole identifier
/// valid.
pub fn lei_check_digits(first18 : String) -> String? {
  let cs = chars_of(first18)
  if cs.length() != 18 || !alnum_only(first18) {
    return None
  }
  let joined : Array[Char] = []
  for c in cs {
    joined.push(c)
  }
  joined.push('0')
  joined.push('0')
  match alnum_mod97(joined) {
    None => None
    Some(rem) => Some(two_digits(98 - rem))
  }
}

///|
/// The four-character local operating unit prefix of an LEI, or None when the
/// identifier is not valid.
pub fn lei_lou(s : String) -> String? {
  if !lei_valid(s) {
    return None
  }
  substring(s, 0, 4)
}
