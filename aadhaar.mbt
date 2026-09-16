// Aadhaar numbers, issued by UIDAI. Twelve digits whose final digit is a
// Verhoeff check digit, so the validation reuses the Verhoeff module.

///|
/// Validate a 12-digit Aadhaar number.
pub fn aadhaar_valid(s : String) -> Bool {
  match digits_of(s) {
    None => false
    Some(d) => d.length() == 12 && verhoeff_valid(s)
  }
}

///|
/// Verhoeff check digit for the first eleven digits of an Aadhaar number.
pub fn aadhaar_check_digit(first11 : String) -> Int? {
  match digits_of(first11) {
    None => None
    Some(d) =>
      if d.length() == 11 {
        verhoeff_check_digit(first11)
      } else {
        None
      }
  }
}
