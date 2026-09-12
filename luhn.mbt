// The Luhn (mod-10) check-digit algorithm, used by payment cards, IMEI
// numbers and several national identifiers.

///|
/// Parse a string of ASCII digits into an array of ints.
/// Returns None if the string is empty or contains a non-digit.
fn digits_of(s : String) -> Array[Int]? {
  let out : Array[Int] = []
  for ch in s {
    if ch < '0' || ch > '9' {
      return None
    }
    out.push(ch.to_int() - '0'.to_int())
  }
  if out.length() == 0 {
    None
  } else {
    Some(out)
  }
}

///|
/// Sum of digits after Luhn weighting. When `double_first` is true the
/// rightmost digit is doubled — that is the layout used when the check digit
/// has not been appended yet.
fn luhn_sum(digits : Array[Int], double_first : Bool) -> Int {
  let mut sum = 0
  let mut double = double_first
  for i = digits.length() - 1; i >= 0; i = i - 1 {
    let mut d = digits[i]
    if double {
      d = d * 2
      if d > 9 {
        d = d - 9
      }
    }
    sum = sum + d
    double = !double
  }
  sum
}

///|
/// Validate a number that already carries its Luhn check digit.
pub fn luhn_valid(s : String) -> Bool {
  match digits_of(s) {
    None => false
    Some(digits) => luhn_sum(digits, false) % 10 == 0
  }
}

///|
/// Compute the Luhn check digit that should be appended to `payload`.
pub fn luhn_check_digit(payload : String) -> Int? {
  match digits_of(payload) {
    None => None
    Some(digits) => Some((10 - luhn_sum(digits, true) % 10) % 10)
  }
}
