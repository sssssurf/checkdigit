// Cadastro Nacional da Pessoa Jurídica, the Brazilian company registry.
// Fourteen digits whose last two are check digits, computed exactly as a CPF's
// are but over twelve base digits instead of nine, and with weight vectors that
// wrap around nine.

///|
/// Weights for the first check digit, over the twelve base digits.
let cnpj_first_weights : Array[Int] = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]

///|
/// Weights for the second check digit, which also covers the first one.
let cnpj_second_weights : Array[Int] = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]

///|
/// The two check digits implied by the first twelve digits of a CNPJ. The
/// digit rule itself is the shared one from the CPF module.
pub fn cnpj_check_digits(first12 : String) -> String? {
  match digits_of(first12) {
    None => None
    Some(d) =>
      if d.length() != 12 {
        None
      } else {
        let mut first_sum = 0
        for i = 0; i < 12; i = i + 1 {
          first_sum = first_sum + d[i] * cnpj_first_weights[i]
        }
        let first = cpf_digit(first_sum)
        let mut second_sum = 0
        for i = 0; i < 12; i = i + 1 {
          second_sum = second_sum + d[i] * cnpj_second_weights[i]
        }
        second_sum = second_sum + first * cnpj_second_weights[12]
        Some(two_digits(first * 10 + cpf_digit(second_sum)))
      }
  }
}

///|
/// Validate a 14-digit CNPJ, including both check digits. Punctuation is not
/// accepted; strip it first.
pub fn cnpj_valid(s : String) -> Bool {
  match digits_of(s) {
    None => false
    Some(d) =>
      if d.length() != 14 {
        false
      } else {
        // As with a CPF, a repdigit satisfies the arithmetic but is never
        // issued.
        let mut all_same = true
        for i = 1; i < 14; i = i + 1 {
          if d[i] != d[0] {
            all_same = false
          }
        }
        if all_same {
          return false
        }
        let mut first_sum = 0
        for i = 0; i < 12; i = i + 1 {
          first_sum = first_sum + d[i] * cnpj_first_weights[i]
        }
        if cpf_digit(first_sum) != d[12] {
          return false
        }
        let mut second_sum = 0
        for i = 0; i < 13; i = i + 1 {
          second_sum = second_sum + d[i] * cnpj_second_weights[i]
        }
        cpf_digit(second_sum) == d[13]
      }
  }
}

///|
/// The usual display form, 00.000.000/0000-00, or None when the input is not
/// fourteen digits.
pub fn cnpj_format(s : String) -> String? {
  match digits_of(s) {
    None => None
    Some(d) =>
      if d.length() != 14 {
        None
      } else {
        let buf = StringBuilder()
        for i = 0; i < 14; i = i + 1 {
          if i == 2 || i == 5 {
            buf.write_char('.')
          }
          if i == 8 {
            buf.write_char('/')
          }
          if i == 12 {
            buf.write_char('-')
          }
          buf.write_char(digit_char(d[i]))
        }
        Some(buf.to_string())
      }
  }
}
