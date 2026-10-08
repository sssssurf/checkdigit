// GS1 retail numbers. The GTIN family — EAN-8, UPC-A, EAN-13 and GTIN-14 —
// shares one mod-10 check digit computed with the alternating 3-1 weighting
// read from the right, and UPC-E is the zero-suppressed form of UPC-A.

///|
/// The GTIN check digit for a payload of digits: the digit that, appended,
/// makes the alternating-weight sum a multiple of ten. Weights are 3 and 1
/// starting with 3 at the rightmost payload digit, which is the weight the
/// position to the left of the check digit always carries. Returns None unless
/// every character is a digit.
pub fn gtin_check_digit(payload : String) -> Int? {
  let cs = chars_of(payload)
  let n = cs.length()
  if n == 0 {
    return None
  }
  let mut sum = 0
  for i = 0; i < n; i = i + 1 {
    let c = cs[i]
    if !is_digit(c) {
      return None
    }
    let d = c.to_int() - '0'.to_int()
    // Distance from the check digit. Odd distances carry weight 3.
    let weight = if (n - i) % 2 == 1 { 3 } else { 1 }
    sum = sum + d * weight
  }
  Some((10 - sum % 10) % 10)
}

///|
/// Validate a numeric code of exactly `len` digits whose last digit is the GTIN
/// check digit for the preceding ones.
fn gtin_code_valid(s : String, len : Int) -> Bool {
  let cs = chars_of(s)
  if cs.length() != len {
    return false
  }
  for c in cs {
    if !is_digit(c) {
      return false
    }
  }
  let body = match substring(s, 0, len - 1) {
    None => return false
    Some(b) => b
  }
  match gtin_check_digit(body) {
    None => false
    Some(d) => d == (cs[len - 1].to_int() - '0'.to_int())
  }
}

///|
/// Validate an eight-digit EAN-8, the short retail code used on small packages.
pub fn ean8_valid(s : String) -> Bool {
  gtin_code_valid(s, 8)
}

///|
/// Validate a twelve-digit UPC-A, the North American retail code.
pub fn upca_valid(s : String) -> Bool {
  gtin_code_valid(s, 12)
}

///|
/// Validate a thirteen-digit EAN-13, the standard international retail code.
/// ISBN-13 and ISSN are both restrictions of this shape.
pub fn ean13_valid(s : String) -> Bool {
  gtin_code_valid(s, 13)
}

///|
/// Validate a fourteen-digit GTIN-14, the shipping-container level of the GTIN
/// hierarchy.
pub fn gtin14_valid(s : String) -> Bool {
  gtin_code_valid(s, 14)
}

///|
/// Validate any GTIN by its own length: eight, twelve, thirteen or fourteen
/// digits. Any other length is invalid, since those are the four registered
/// GTIN sizes.
pub fn gtin_valid(s : String) -> Bool {
  let n = match digit_count(s) {
    None => return false
    Some(n) => n
  }
  if n != 8 && n != 12 && n != 13 && n != 14 {
    return false
  }
  gtin_code_valid(s, n)
}

///|
/// The eleven-digit UPC-A payload — number system, manufacturer, item — that a
/// UPC-E stands for. Reads the first seven characters of `s`; the check digit is
/// not part of the result. Returns None unless they are a number system 0 or 1
/// followed by six digits.
fn upce_payload(s : String) -> String? {
  let cs = chars_of(s)
  if cs.length() < 7 {
    return None
  }
  let ns = cs[0]
  if ns != '0' && ns != '1' {
    return None
  }
  let d : Array[Char] = []
  for i = 1; i <= 6; i = i + 1 {
    let c = cs[i]
    if !is_digit(c) {
      return None
    }
    d.push(c)
  }
  let buf = StringBuilder()
  buf.write_char(ns)
  let last = d[5]
  // The sixth data digit says where the suppressed zeroes were.
  if last == '0' || last == '1' || last == '2' {
    buf.write_char(d[0])
    buf.write_char(d[1])
    buf.write_char(last)
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char(d[2])
    buf.write_char(d[3])
    buf.write_char(d[4])
  } else if last == '3' {
    buf.write_char(d[0])
    buf.write_char(d[1])
    buf.write_char(d[2])
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char(d[3])
    buf.write_char(d[4])
  } else if last == '4' {
    buf.write_char(d[0])
    buf.write_char(d[1])
    buf.write_char(d[2])
    buf.write_char(d[3])
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char(d[4])
  } else {
    buf.write_char(d[0])
    buf.write_char(d[1])
    buf.write_char(d[2])
    buf.write_char(d[3])
    buf.write_char(d[4])
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char('0')
    buf.write_char(last)
  }
  Some(buf.to_string())
}

///|
/// The UPC-A check digit implied by the first seven characters of a UPC-E.
pub fn upce_check_digit(first7 : String) -> Int? {
  match upce_payload(first7) {
    None => None
    Some(p) => gtin_check_digit(p)
  }
}

///|
/// Expand an eight-character UPC-E to the twelve-digit UPC-A it stands for. The
/// check digit is recomputed from the expanded payload, so a UPC-E whose own
/// check digit is wrong still expands to a well-formed UPC-A. Returns None
/// unless the input is eight digits with a number system of 0 or 1.
pub fn upce_expand(s : String) -> String? {
  let cs = chars_of(s)
  if cs.length() != 8 || !is_digit(cs[7]) {
    return None
  }
  match upce_payload(s) {
    None => None
    Some(p) =>
      match gtin_check_digit(p) {
        None => None
        Some(cd) => Some(p + char_str(digit_char(cd)))
      }
  }
}

///|
/// Validate an eight-character UPC-E. Its check digit must equal the one the
/// expanded UPC-A would carry.
pub fn upce_valid(s : String) -> Bool {
  let cs = chars_of(s)
  if cs.length() != 8 {
    return false
  }
  match upce_check_digit(s) {
    None => false
    Some(cd) => cd == (cs[7].to_int() - '0'.to_int())
  }
}
