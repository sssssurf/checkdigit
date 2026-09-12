// The Damm check-digit algorithm, based on a weakly totally anti-symmetric
// quasigroup. It catches all single-digit errors and all adjacent
// transpositions, using a single table lookup per digit.

///|
/// The quasigroup table. Every row has a zero on the anti-diagonal, which is
/// what makes the running value itself usable as the check digit.
let damm_table : Array[Array[Int]] = [
  [0, 3, 1, 7, 5, 9, 8, 6, 4, 2],
  [7, 0, 9, 2, 1, 5, 4, 8, 6, 3],
  [4, 2, 0, 6, 8, 7, 1, 3, 5, 9],
  [1, 7, 5, 0, 9, 8, 3, 4, 2, 6],
  [6, 1, 2, 3, 0, 4, 5, 9, 7, 8],
  [3, 6, 7, 4, 2, 0, 9, 5, 8, 1],
  [5, 8, 6, 9, 7, 2, 0, 1, 3, 4],
  [8, 9, 4, 5, 3, 6, 2, 0, 1, 7],
  [9, 4, 3, 8, 6, 1, 7, 2, 0, 5],
  [2, 5, 8, 1, 4, 3, 6, 7, 9, 0],
]

///|
/// Running value used by both validation and check-digit generation.
fn damm_interim(digits : Array[Int]) -> Int {
  let mut interim = 0
  for d in digits {
    interim = damm_table[interim][d]
  }
  interim
}

///|
/// Validate a number that already carries its Damm check digit.
pub fn damm_valid(s : String) -> Bool {
  match digits_of(s) {
    None => false
    Some(digits) => damm_interim(digits) == 0
  }
}

///|
/// Compute the Damm check digit that should be appended to `payload`.
pub fn damm_check_digit(payload : String) -> Int? {
  match digits_of(payload) {
    None => None
    Some(digits) => Some(damm_interim(digits))
  }
}
