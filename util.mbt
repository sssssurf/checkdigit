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
