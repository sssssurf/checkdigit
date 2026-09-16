// Small internal helpers shared by the identifier validators.

///|
/// ASCII-only uppercase. Non-letters (and non-ASCII) are returned unchanged.
fn upper_ascii(c : Char) -> Char {
  match c {
    'a' => 'A'
    'b' => 'B'
    'c' => 'C'
    'd' => 'D'
    'e' => 'E'
    'f' => 'F'
    'g' => 'G'
    'h' => 'H'
    'i' => 'I'
    'j' => 'J'
    'k' => 'K'
    'l' => 'L'
    'm' => 'M'
    'n' => 'N'
    'o' => 'O'
    'p' => 'P'
    'q' => 'Q'
    'r' => 'R'
    's' => 'S'
    't' => 'T'
    'u' => 'U'
    'v' => 'V'
    'w' => 'W'
    'x' => 'X'
    'y' => 'Y'
    'z' => 'Z'
    _ => c
  }
}

///|
/// Extract `len` characters starting at `start`. Returns None when the range
/// falls outside the string.
fn substring(s : String, start : Int, len : Int) -> String? {
  let chars : Array[Char] = []
  for ch in s {
    chars.push(ch)
  }
  if start < 0 || len < 0 || start + len > chars.length() {
    return None
  }
  let buf = StringBuilder()
  for i = start; i < start + len; i = i + 1 {
    buf.write_char(chars[i])
  }
  Some(buf.to_string())
}

///|
/// Split a string into its characters.
fn chars_of(s : String) -> Array[Char] {
  let chars : Array[Char] = []
  for ch in s {
    chars.push(ch)
  }
  chars
}

///|
/// True when `c` is an ASCII digit.
fn is_digit(c : Char) -> Bool {
  c >= '0' && c <= '9'
}

///|
/// True when `c` is an ASCII uppercase letter.
fn is_alpha(c : Char) -> Bool {
  c >= 'A' && c <= 'Z'
}

///|
/// Numeric value of a digit or letter, expanding letters to 10..35 as the ISO
/// identifier schemes require. Returns None for anything else.
fn alnum_value(c : Char) -> Int? {
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
/// A one-character string.
fn char_str(c : Char) -> String {
  let buf = StringBuilder()
  buf.write_char(c)
  buf.to_string()
}

///|
/// Remainder modulo 97 after expanding every character to its numeric value:
/// digits keep their value, letters become 10..35. Returns None when a
/// character is neither.
fn alnum_mod97(cs : Array[Char]) -> Int? {
  let mut rem = 0
  for c in cs {
    let v = match alnum_value(c) {
      None => return None
      Some(v) => v
    }
    if v >= 10 {
      rem = rem * 10 + v / 10
      rem = rem % 97
    }
    rem = rem * 10 + v % 10
    rem = rem % 97
  }
  Some(rem)
}

///|
/// True when every character is an ASCII letter or digit.
fn alnum_only(s : String) -> Bool {
  let cs = chars_of(s)
  if cs.length() == 0 {
    return false
  }
  for c in cs {
    if !is_digit(c) && !is_alpha(upper_ascii(c)) {
      return false
    }
  }
  true
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
    if !is_digit(c) {
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
