// Cadastro de Pessoas Físicas, the Brazilian individual taxpayer registry.
// Eleven digits whose last two are check digits. Each is the complement of a
// weighted sum taken modulo 11, over the nine digits before them and then the
// ten digits before them.

///|
/// Weights for the first check digit, descending from ten over the nine digits.
let cpf_first_weights : Array[Int] = [10, 9, 8, 7, 6, 5, 4, 3, 2]

///|
/// Weights for the second check digit, which also covers the first one.
let cpf_second_weights : Array[Int] = [11, 10, 9, 8, 7, 6, 5, 4, 3, 2]

///|
/// Turn a weighted sum into its check digit. Remainders of zero and one both
/// fold to zero rather than to eleven and ten, which is what keeps the result a
/// single digit.
fn cpf_digit(sum : Int) -> Int {
  let r = sum % 11
  if r < 2 {
    0
  } else {
    11 - r
  }
}

///|
/// The two check digits implied by the first nine digits of a CPF.
pub fn cpf_check_digits(first9 : String) -> String? {
  match digits_of(first9) {
    None => None
    Some(d) =>
      if d.length() != 9 {
        None
      } else {
        let mut first_sum = 0
        for i = 0; i < 9; i = i + 1 {
          first_sum = first_sum + d[i] * cpf_first_weights[i]
        }
        let first = cpf_digit(first_sum)
        let mut second_sum = 0
        for i = 0; i < 9; i = i + 1 {
          second_sum = second_sum + d[i] * cpf_second_weights[i]
        }
        second_sum = second_sum + first * cpf_second_weights[9]
        Some(two_digits(first * 10 + cpf_digit(second_sum)))
      }
  }
}

///|
/// Validate an 11-digit CPF, including both check digits. Punctuation is not
/// accepted; strip it first.
pub fn cpf_valid(s : String) -> Bool {
  match digits_of(s) {
    None => false
    Some(d) =>
      if d.length() != 11 {
        false
      } else {
        // A repdigit such as 00000000000 satisfies the arithmetic but is never
        // issued, so the usual validators reject the whole class.
        let mut all_same = true
        for i = 1; i < 11; i = i + 1 {
          if d[i] != d[0] {
            all_same = false
          }
        }
        if all_same {
          return false
        }
        let mut first_sum = 0
        for i = 0; i < 9; i = i + 1 {
          first_sum = first_sum + d[i] * cpf_first_weights[i]
        }
        if cpf_digit(first_sum) != d[9] {
          return false
        }
        let mut second_sum = 0
        for i = 0; i < 10; i = i + 1 {
          second_sum = second_sum + d[i] * cpf_second_weights[i]
        }
        cpf_digit(second_sum) == d[10]
      }
  }
}

///|
/// The usual display form, 000.000.000-00, or None when the input is not
/// eleven digits.
pub fn cpf_format(s : String) -> String? {
  match digits_of(s) {
    None => None
    Some(d) =>
      if d.length() != 11 {
        None
      } else {
        let buf = StringBuilder()
        for i = 0; i < 11; i = i + 1 {
          if i == 3 || i == 6 {
            buf.write_char('.')
          }
          if i == 9 {
            buf.write_char('-')
          }
          buf.write_char(digit_char(d[i]))
        }
        Some(buf.to_string())
      }
  }
}
