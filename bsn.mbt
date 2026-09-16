// Burgerservicenummer, the Dutch citizen service number. Nine digits checked
// with the eleven test: the digits weighted from nine down to one, except that
// the last is negated, must sum to a multiple of eleven. Unlike the other
// identifiers here there is no separate check digit appended to the end — the
// property holds over all nine.

///|
/// The eleven-test weights. Negating the last position is what stops a Dutch
/// bank account number, checked with the same weights all positive, from also
/// passing as a BSN.
let bsn_weights : Array[Int] = [9, 8, 7, 6, 5, 4, 3, 2, -1]

///|
/// The nine digits of a BSN, left-padded with a zero when only eight were
/// written, which is how older numbers are commonly recorded.
fn bsn_digits(s : String) -> Array[Int]? {
  match digits_of(s) {
    None => None
    Some(d) =>
      if d.length() == 9 {
        Some(d)
      } else if d.length() == 8 {
        let out : Array[Int] = [0]
        for x in d {
          out.push(x)
        }
        Some(out)
      } else {
        None
      }
  }
}

///|
/// Validate a BSN. Both the nine-digit form and the eight-digit form with its
/// leading zero omitted are accepted. An all-zero number satisfies the
/// arithmetic but is never issued, so it is rejected.
pub fn bsn_valid(s : String) -> Bool {
  match bsn_digits(s) {
    None => false
    Some(d) => {
      let mut sum = 0
      let mut all_zero = true
      for i = 0; i < 9; i = i + 1 {
        if d[i] != 0 {
          all_zero = false
        }
        sum = sum + d[i] * bsn_weights[i]
      }
      !all_zero && sum % 11 == 0
    }
  }
}

///|
/// The ninth digit implied by the first eight. Returns None when the first
/// eight digits do not fix a digit, which happens when the required value would
/// have to be ten.
pub fn bsn_check_digit(first8 : String) -> Int? {
  match digits_of(first8) {
    None => None
    Some(d) =>
      if d.length() != 8 {
        None
      } else {
        let mut sum = 0
        for i = 0; i < 8; i = i + 1 {
          sum = sum + d[i] * bsn_weights[i]
        }
        let r = sum % 11
        if r == 10 {
          None
        } else {
          Some(r)
        }
      }
  }
}
