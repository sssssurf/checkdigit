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
