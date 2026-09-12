// IMEI (International Mobile Equipment Identity) validation and decoding.
// A 15-digit IMEI is 8 digits of TAC, 6 digits of serial number, and one
// Luhn check digit.

///|
/// Validate a complete 15-digit IMEI, including its Luhn check digit.
pub fn imei_valid(s : String) -> Bool {
  match digits_of(s) {
    None => false
    Some(d) => d.length() == 15 && luhn_valid(s)
  }
}

///|
/// Compute the check digit for the first 14 digits of an IMEI.
pub fn imei_check_digit(first14 : String) -> Int? {
  match digits_of(first14) {
    Some(d) => if d.length() == 14 { luhn_check_digit(first14) } else { None }
    None => None
  }
}

///|
/// The Type Allocation Code: the first 8 digits of an IMEI.
pub fn imei_tac(s : String) -> String? {
  substring(s, 0, 8)
}

///|
/// The 6-digit serial number: digits 9 through 14 of an IMEI.
pub fn imei_serial(s : String) -> String? {
  substring(s, 8, 6)
}
