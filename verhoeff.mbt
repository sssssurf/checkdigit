// The Verhoeff check-digit algorithm, based on the dihedral group D5.
// It catches all single-digit errors and all adjacent transpositions.

///|
/// Multiplication table of the dihedral group D5.
let verhoeff_d : Array[Array[Int]] = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 2, 3, 4, 0, 6, 7, 8, 9, 5],
  [2, 3, 4, 0, 1, 7, 8, 9, 5, 6],
  [3, 4, 0, 1, 2, 8, 9, 5, 6, 7],
  [4, 0, 1, 2, 3, 9, 5, 6, 7, 8],
  [5, 9, 8, 7, 6, 0, 4, 3, 2, 1],
  [6, 5, 9, 8, 7, 1, 0, 4, 3, 2],
  [7, 6, 5, 9, 8, 2, 1, 0, 4, 3],
  [8, 7, 6, 5, 9, 3, 2, 1, 0, 4],
  [9, 8, 7, 6, 5, 4, 3, 2, 1, 0],
]

///|
/// Permutation table, indexed by digit position modulo 8.
let verhoeff_p : Array[Array[Int]] = [
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
  [1, 5, 7, 6, 2, 8, 3, 0, 9, 4],
  [5, 8, 0, 3, 7, 9, 6, 1, 4, 2],
  [8, 9, 1, 6, 0, 4, 3, 5, 2, 7],
  [9, 4, 5, 3, 1, 2, 6, 8, 7, 0],
  [4, 2, 8, 6, 5, 7, 3, 9, 0, 1],
  [2, 7, 9, 3, 8, 0, 6, 4, 1, 5],
  [7, 0, 4, 6, 9, 1, 3, 2, 5, 8],
]

///|
/// Multiplicative inverse table, used to produce a check digit.
let verhoeff_inv : Array[Int] = [0, 4, 3, 2, 1, 5, 6, 7, 8, 9]

///|
/// Validate a number that already carries its Verhoeff check digit.
pub fn verhoeff_valid(s : String) -> Bool {
  match digits_of(s) {
    None => false
    Some(digits) => {
      let mut c = 0
      for i = 0; i < digits.length(); i = i + 1 {
        let d = digits[digits.length() - 1 - i]
        c = verhoeff_d[c][verhoeff_p[i % 8][d]]
      }
      c == 0
    }
  }
}

///|
/// Compute the Verhoeff check digit that should be appended to `payload`.
pub fn verhoeff_check_digit(payload : String) -> Int? {
  match digits_of(payload) {
    None => None
    Some(digits) => {
      let mut c = 0
      for i = 0; i < digits.length(); i = i + 1 {
        let d = digits[digits.length() - 1 - i]
        c = verhoeff_d[c][verhoeff_p[(i + 1) % 8][d]]
      }
      Some(verhoeff_inv[c])
    }
  }
}
