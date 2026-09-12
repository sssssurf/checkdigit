// IBAN (International Bank Account Number) validation, per ISO 13616.
// An IBAN is a 2-letter country code, 2 check digits, then a country-specific
// account part. The check digits are validated with the mod-97-10 scheme.

///|
/// Registered IBAN lengths by country code. An IBAN that starts with a code
/// missing from this table cannot be validated.
let iban_lengths : Array[(String, Int)] = [
  ("AD", 24),
  ("AE", 23),
  ("AL", 28),
  ("AT", 20),
  ("AZ", 28),
  ("BA", 20),
  ("BE", 16),
  ("BG", 22),
  ("BH", 22),
  ("BR", 29),
  ("BY", 28),
  ("CH", 21),
  ("CR", 22),
  ("CY", 28),
  ("CZ", 24),
  ("DE", 22),
  ("DK", 18),
  ("DO", 28),
  ("EE", 20),
  ("EG", 29),
  ("ES", 24),
  ("FI", 18),
  ("FO", 18),
  ("FR", 27),
  ("GB", 22),
  ("GE", 22),
  ("GI", 23),
  ("GL", 18),
  ("GR", 27),
  ("GT", 28),
  ("HR", 21),
  ("HU", 28),
  ("IE", 22),
  ("IL", 23),
  ("IQ", 23),
  ("IS", 26),
  ("IT", 27),
  ("JO", 30),
  ("KW", 30),
  ("KZ", 20),
  ("LB", 28),
  ("LC", 32),
  ("LI", 21),
  ("LT", 20),
  ("LU", 20),
  ("LV", 21),
  ("MC", 27),
  ("MD", 24),
  ("ME", 22),
  ("MK", 19),
  ("MR", 27),
  ("MT", 31),
  ("MU", 30),
  ("NL", 18),
  ("NO", 15),
  ("PK", 24),
  ("PL", 28),
  ("PS", 29),
  ("PT", 25),
  ("QA", 29),
  ("RO", 24),
  ("RS", 22),
  ("SA", 24),
  ("SC", 31),
  ("SE", 24),
  ("SI", 19),
  ("SK", 24),
  ("SM", 27),
  ("ST", 25),
  ("SV", 28),
  ("TL", 23),
  ("TN", 24),
  ("TR", 26),
  ("UA", 29),
  ("VA", 22),
  ("VG", 24),
  ("XK", 20),
]

///|
/// The registered IBAN length for a country code, or None if unrecognised.
pub fn iban_expected_length(cc : String) -> Int? {
  for entry in iban_lengths {
    if entry.0 == cc {
      return Some(entry.1)
    }
  }
  None
}

///|
/// Strip spaces and uppercase so a human-formatted IBAN can be checked.
/// Only ASCII letters and digits survive.
pub fn iban_normalize(s : String) -> String {
  let buf = StringBuilder()
  for ch in s {
    let u = upper_ascii(ch)
    if (u >= 'A' && u <= 'Z') || (u >= '0' && u <= '9') {
      buf.write_char(u)
    }
  }
  buf.to_string()
}

///|
/// Numeric value of an IBAN character: digits keep their value, letters map
/// to 10..35 (so 'A' is 10 and 'Z' is 35) as required by ISO 13616.
fn iban_char_value(c : Char) -> Int {
  if c >= '0' && c <= '9' {
    c.to_int() - '0'.to_int()
  } else {
    10 + (c.to_int() - 'A'.to_int())
  }
}

///|
/// Remainder modulo 97 of a character sequence, expanding each character to
/// its numeric value. Two digits are folded in for each letter.
fn mod97_of(cs : Array[Char]) -> Int {
  let mut rem = 0
  for c in cs {
    let v = iban_char_value(c)
    if v >= 10 {
      rem = rem * 10 + v / 10
      rem = rem % 97
    }
    rem = rem * 10 + v % 10
    rem = rem % 97
  }
  rem
}

///|
/// Remainder of the rearranged IBAN modulo 97. The first four characters are
/// moved to the end first, as ISO 13616 prescribes.
fn iban_mod97(cs : Array[Char]) -> Int {
  let n = cs.length()
  let rotated : Array[Char] = []
  for i = 0; i < n; i = i + 1 {
    rotated.push(cs[(i + 4) % n])
  }
  mod97_of(rotated)
}

///|
/// Write a value below 100 as exactly two digits.
fn two_digits(v : Int) -> String {
  if v < 10 {
    "0" + v.to_string()
  } else {
    v.to_string()
  }
}

///|
/// True when the first two characters are ASCII letters.
fn alpha_prefix(cs : Array[Char]) -> Bool {
  cs.length() >= 2 &&
  cs[0] >= 'A' &&
  cs[0] <= 'Z' &&
  cs[1] >= 'A' &&
  cs[1] <= 'Z'
}

///|
/// True when characters 3 and 4 are digits.
fn digit_check_positions(cs : Array[Char]) -> Bool {
  cs.length() >= 4 &&
  cs[2] >= '0' &&
  cs[2] <= '9' &&
  cs[3] >= '0' &&
  cs[3] <= '9'
}

///|
/// Validate an IBAN, ignoring spaces and case. Checks the country code, the
/// registered length for that country, and the mod-97 check digits.
pub fn iban_valid(s : String) -> Bool {
  let canon = iban_normalize(s)
  let cs = chars_of(canon)
  let n = cs.length()
  if n < 4 || n > 34 {
    return false
  }
  if !alpha_prefix(cs) || !digit_check_positions(cs) {
    return false
  }
  let cc = match substring(canon, 0, 2) {
    Some(x) => x
    None => return false
  }
  match iban_expected_length(cc) {
    None => false
    Some(expected) => n == expected && iban_mod97(cs) == 1
  }
}

///|
/// The two-letter country code of an IBAN, or None when it is malformed.
pub fn iban_country(s : String) -> String? {
  let canon = iban_normalize(s)
  let cs = chars_of(canon)
  if !alpha_prefix(cs) {
    return None
  }
  substring(canon, 0, 2)
}

///|
/// Group a valid IBAN into blocks of four for display, e.g.
/// "GB82 WEST 1234 5698 7654 32". Returns None when the input is not valid.
pub fn iban_format(s : String) -> String? {
  let canon = iban_normalize(s)
  if !iban_valid(canon) {
    return None
  }
  let cs = chars_of(canon)
  let buf = StringBuilder()
  for i = 0; i < cs.length(); i = i + 1 {
    if i > 0 && i % 4 == 0 {
      buf.write_char(' ')
    }
    buf.write_char(cs[i])
  }
  Some(buf.to_string())
}

///|
/// The country part of an IBAN: everything after the four-character header.
pub fn iban_bban(s : String) -> String? {
  let canon = iban_normalize(s)
  let cs = chars_of(canon)
  if !iban_valid(canon) {
    return None
  }
  substring(canon, 4, cs.length() - 4)
}

///|
/// Compute the two check digits that turn a country code and BBAN into a
/// complete IBAN. For example `iban_check_digits("GB", "WEST12345698765432")`
/// gives "82". The country must be registered and the total length must match
/// the registered length for that country.
pub fn iban_check_digits(country : String, bban : String) -> String? {
  let cc = iban_normalize(country)
  let body = iban_normalize(bban)
  let ccs = chars_of(cc)
  if !alpha_prefix(ccs) || ccs.length() != 2 {
    return None
  }
  if body.length() == 0 {
    return None
  }
  let expected = match iban_expected_length(cc) {
    None => return None
    Some(n) => n
  }
  let joined = chars_of(body)
  if ccs.length() + joined.length() + 2 != expected {
    return None
  }
  for c in ccs {
    joined.push(c)
  }
  joined.push('0')
  joined.push('0')
  Some(two_digits(98 - mod97_of(joined)))
}

///|
/// Assemble a complete IBAN from a country code and a BBAN. The result is
/// always check-digit correct; it is not checked against any national BBAN
/// format, only against the ISO 13616 length and check digits.
pub fn iban_assemble(country : String, bban : String) -> String? {
  match iban_check_digits(country, bban) {
    None => None
    Some(cd) => {
      let s = iban_normalize(country) + cd + iban_normalize(bban)
      if iban_valid(s) {
        Some(s)
      } else {
        None
      }
    }
  }
}
