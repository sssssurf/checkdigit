// Whitebox tests: these exercise the package-private helpers directly.

///|
test "digits_of accepts digit strings" {
  assert_eq(digits_of("123").unwrap().length(), 3)
  assert_eq(digits_of("0").unwrap().length(), 1)
}

///|
test "digits_of rejects empty and non-digit input" {
  assert_true(digits_of("") is None)
  assert_true(digits_of("12a") is None)
  assert_true(digits_of(" 12") is None)
  assert_true(digits_of("-1") is None)
}

///|
test "luhn_sum weights alternate digits" {
  // Without doubling the rightmost: 3 + 2*2 + 1 = 8.
  assert_eq(luhn_sum([1, 2, 3], false), 8)
  // Doubling the rightmost: 3*2 + 2 + 1*2 = 10.
  assert_eq(luhn_sum([1, 2, 3], true), 10)
  // A doubling that spills over 9 folds back by 9: 8*2 = 16 -> 7.
  assert_eq(luhn_sum([8], true), 7)
  assert_eq(luhn_sum([8], false), 8)
}

///|
test "substring clamps to the string bounds" {
  assert_eq(substring("hello", 1, 3).unwrap(), "ell")
  assert_eq(substring("hello", 0, 5).unwrap(), "hello")
  assert_eq(substring("hi", 1, 1).unwrap(), "i")
  assert_true(substring("hi", 0, 5) is None)
  assert_true(substring("hi", -1, 2) is None)
}

///|
test "chars_of splits a string" {
  assert_eq(chars_of("abc").length(), 3)
  assert_eq(chars_of("").length(), 0)
}

///|
test "upper_ascii only touches lowercase letters" {
  assert_eq(upper_ascii('a'), 'A')
  assert_eq(upper_ascii('z'), 'Z')
  assert_eq(upper_ascii('m'), 'M')
  assert_eq(upper_ascii('5'), '5')
  assert_eq(upper_ascii('-'), '-')
}

///|
test "leading_int parses a digit prefix" {
  assert_eq(leading_int("456", 3).unwrap(), 456)
  assert_eq(leading_int("4567", 2).unwrap(), 45)
  assert_true(leading_int("45", 3) is None)
  assert_true(leading_int("4a6", 3) is None)
}

///|
test "prefix_in compares numeric ranges" {
  assert_true(prefix_in("4111111111111111", 1, 4, 4))
  assert_true(prefix_in("5555555555554444", 2, 51, 55))
  assert_false(prefix_in("9999999999999999", 2, 51, 55))
  assert_false(prefix_in("4", 2, 51, 55))
}

///|
test "digit_count counts only digits" {
  assert_eq(digit_count("123").unwrap(), 3)
  assert_true(digit_count("12a") is None)
  assert_true(digit_count("") is None)
}

///|
test "damm table is anti-symmetric along the diagonal" {
  for i = 0; i < 10; i = i + 1 {
    assert_eq(damm_table[i][i], 0)
  }
  // Every row is a permutation of 0..9.
  for i = 0; i < 10; i = i + 1 {
    let seen : Array[Int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    for j = 0; j < 10; j = j + 1 {
      seen[damm_table[i][j]] = 1
    }
    let mut total = 0
    for j = 0; j < 10; j = j + 1 {
      total = total + seen[j]
    }
    assert_eq(total, 10)
  }
}

///|
test "damm_interim folds digits through the table" {
  // The standard worked example: 572 has check digit 4.
  assert_eq(damm_interim([5, 7, 2]), 4)
  assert_eq(damm_interim([]), 0)
}

///|
test "verhoeff tables have the expected structure" {
  for i = 0; i < 10; i = i + 1 {
    assert_eq(verhoeff_d[i][0], i)
    assert_eq(verhoeff_d[0][i], i)
    assert_eq(verhoeff_p[0][i], i)
  }
  // The multiplicative inverse table undoes the group multiplication.
  for i = 0; i < 10; i = i + 1 {
    assert_eq(verhoeff_d[i][verhoeff_inv[i]], 0)
  }
}

///|
test "iban helpers implement the ISO 13616 mapping" {
  assert_eq(iban_char_value('0'), 0)
  assert_eq(iban_char_value('9'), 9)
  assert_eq(iban_char_value('A'), 10)
  assert_eq(iban_char_value('Z'), 35)
  assert_eq(iban_normalize("gb82 west 1234"), "GB82WEST1234")
  assert_eq(iban_normalize("de89-3704"), "DE893704")
  assert_eq(iban_expected_length("GB").unwrap(), 22)
  assert_eq(iban_expected_length("DE").unwrap(), 22)
  assert_true(iban_expected_length("ZZ") is None)
}

///|
test "alnum_value expands letters to 10..35" {
  assert_eq(alnum_value('0').unwrap(), 0)
  assert_eq(alnum_value('9').unwrap(), 9)
  assert_eq(alnum_value('A').unwrap(), 10)
  assert_eq(alnum_value('Z').unwrap(), 35)
  // Lowercase is folded first.
  assert_eq(alnum_value('z').unwrap(), 35)
  assert_true(alnum_value('-') is None)
  assert_true(alnum_value(' ') is None)
}

///|
test "alnum_mod97 matches a direct big-integer evaluation" {
  // A, B and C expand to 10, 11 and 12, so the digit string is "101112".
  assert_eq(alnum_mod97(chars_of("ABC")).unwrap(), 101112 % 97)
  assert_eq(alnum_mod97(chars_of("123")).unwrap(), 123 % 97)
  assert_eq(alnum_mod97(chars_of("")).unwrap(), 0)
  assert_true(alnum_mod97(chars_of("A-1")) is None)
}

///|
test "alnum_only rejects empty and punctuation" {
  assert_true(alnum_only("ABC123"))
  assert_true(alnum_only("abc"))
  assert_false(alnum_only(""))
  assert_false(alnum_only("AB C"))
  assert_false(alnum_only("AB-1"))
}

///|
test "cn_id_expected computes the GB 11643 check character" {
  // Worked example from the standard: the weighted sum is 167, 167 % 11 is 2.
  let cs = chars_of("11010519491231002")
  assert_eq(cn_id_expected(cs).unwrap(), 'X')
  // A non-digit in the payload is rejected.
  assert_true(cn_id_expected(chars_of("1101051949123100A")) is None)
}

///|
test "cn_id_date_plausible bounds the birth date" {
  assert_true(cn_id_date_plausible(chars_of("11010519491231002X")))
  assert_true(cn_id_date_plausible(chars_of("11010518000101002X")))
  assert_true(cn_id_date_plausible(chars_of("11010521991231002X")))
  assert_false(cn_id_date_plausible(chars_of("11010517991231002X")))
  assert_false(cn_id_date_plausible(chars_of("11010522001231002X")))
  assert_false(cn_id_date_plausible(chars_of("11010519490031002X")))
  assert_false(cn_id_date_plausible(chars_of("11010519491331002X")))
  assert_false(cn_id_date_plausible(chars_of("11010519490a31002X")))
}

///|
test "vin_value transliterates and rejects I, O and Q" {
  assert_eq(vin_value('1').unwrap(), 1)
  assert_eq(vin_value('0').unwrap(), 0)
  assert_eq(vin_value('A').unwrap(), 1)
  assert_eq(vin_value('H').unwrap(), 8)
  assert_eq(vin_value('R').unwrap(), 9)
  assert_eq(vin_value('X').unwrap(), 7)
  assert_eq(vin_value('z').unwrap(), 9)
  assert_true(vin_value('I') is None)
  assert_true(vin_value('O') is None)
  assert_true(vin_value('Q') is None)
  assert_true(vin_value('-') is None)
}

///|
test "isin_expanded writes two digits per letter" {
  // A=10, U=30, X=33, V=31, G=16, Z=35, so the ISO example expands as below.
  assert_eq(isin_expanded("AU0000XVGZA").unwrap(), "103000003331163510")
  assert_eq(isin_expanded("123").unwrap(), "123")
  assert_true(isin_expanded("US-1") is None)
}

///|
test "uscc tables describe the same 31-character code set" {
  assert_eq(uscc_chars.length(), 31)
  assert_eq(uscc_weights.length(), 17)
  for i = 0; i < 31; i = i + 1 {
    assert_eq(uscc_value(uscc_chars[i]).unwrap(), i)
  }
  // I, O, S, V and Z have no value; every other letter does.
  for c in ['I', 'O', 'S', 'V', 'Z'] {
    assert_true(uscc_value(c) is None)
  }
  assert_eq(uscc_value('A').unwrap(), 10)
  assert_eq(uscc_value('H').unwrap(), 17)
  assert_eq(uscc_value('J').unwrap(), 18)
  assert_eq(uscc_value('N').unwrap(), 22)
  assert_eq(uscc_value('Y').unwrap(), 30)
  assert_true(uscc_value('-') is None)
  assert_true(uscc_value(' ') is None)
}

///|
test "uscc weights are the powers of three modulo 31" {
  // The specification derives them this way rather than listing them.
  let mut p = 1
  let mut i = 0
  while i < 17 {
    assert_eq(uscc_weights[i], p)
    p = p * 3 % 31
    i = i + 1
  }
}

///|
test "cpf_digit folds the two remainders needing two digits" {
  assert_eq(cpf_digit(0), 0)
  assert_eq(cpf_digit(1), 0)
  assert_eq(cpf_digit(2), 9)
  assert_eq(cpf_digit(10), 1)
  assert_eq(cpf_digit(11), 0)
  assert_eq(cpf_digit(12), 0)
  assert_eq(cpf_digit(13), 9)
}

///|
test "cf tables share a prefix and diverge after J" {
  // Digits and the first ten letters reuse one sequence in the odd table, and
  // the even table is the plain value throughout.
  for i = 0; i < 10; i = i + 1 {
    assert_eq(cf_odd[i], cf_odd[i + 10])
    assert_eq(cf_even[i], i)
    assert_eq(cf_even[i + 10], i)
  }
  assert_eq(cf_even[35], 25)
  assert_eq(cf_odd[35], 23)
  // Values repeat, so the odd table cannot be derived from the index.
  assert_eq(cf_odd[10], 1)
  assert_eq(cf_odd[20], 2)
}

///|
test "cf character classes" {
  assert_eq(cf_month_codes.length(), 12)
  for c in cf_month_codes {
    assert_true(cf_month_char(c))
  }
  assert_true(cf_month_char('a'))
  assert_false(cf_month_char('F'))
  assert_false(cf_month_char('G'))
  assert_eq(cf_omocodia_letters.length(), 10)
  assert_true(cf_numeric_char('5'))
  assert_true(cf_numeric_char('L'))
  assert_true(cf_numeric_char('v'))
  assert_false(cf_numeric_char('A'))
  assert_false(cf_numeric_char('K'))
  assert_false(cf_numeric_char('-'))
}

///|
test "digit_char round-trips every digit" {
  for i = 0; i < 10; i = i + 1 {
    assert_eq(digit_char(i), digit_chars[i])
  }
  assert_eq(digit_char(-1), '0')
  assert_eq(digit_char(10), '9')
}

///|
test "bsn weights negate the last position only" {
  assert_eq(bsn_weights.length(), 9)
  for i = 0; i < 8; i = i + 1 {
    assert_eq(bsn_weights[i], 9 - i)
  }
  assert_eq(bsn_weights[8], -1)
}

///|
test "bsn_digits pads the eight-digit form" {
  assert_eq(bsn_digits("111222333").unwrap().length(), 9)
  let padded = bsn_digits("10000008").unwrap()
  assert_eq(padded.length(), 9)
  assert_eq(padded[0], 0)
  assert_eq(padded[1], 1)
  assert_true(bsn_digits("1112223") is None)
  assert_true(bsn_digits("1112223334") is None)
  assert_true(bsn_digits("11122233a") is None)
}
