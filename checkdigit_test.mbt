// Blackbox tests: these only use the public API, as an outside caller would.

///|
test "luhn validates known numbers" {
  assert_true(luhn_valid("79927398713"))
  assert_true(luhn_valid("4111111111111111"))
  assert_true(luhn_valid("17893729974"))
  assert_false(luhn_valid("79927398710"))
  assert_false(luhn_valid("79927398711"))
  assert_false(luhn_valid(""))
  assert_false(luhn_valid("4111-1111-1111-1111"))
}

///|
test "luhn check digit matches the reference vectors" {
  assert_eq(luhn_check_digit("7992739871").unwrap(), 3)
  assert_eq(luhn_check_digit("411111111111111").unwrap(), 1)
  assert_eq(luhn_check_digit("1234").unwrap(), 4)
  assert_true(luhn_check_digit("") is None)
  assert_true(luhn_check_digit("12a") is None)
}

///|
test "verhoeff validates known numbers" {
  assert_true(verhoeff_valid("2363"))
  assert_true(verhoeff_valid("123451"))
  assert_false(verhoeff_valid("2362"))
  assert_false(verhoeff_valid("123450"))
  assert_false(verhoeff_valid(""))
}

///|
test "verhoeff check digit matches the reference vectors" {
  assert_eq(verhoeff_check_digit("236").unwrap(), 3)
  assert_eq(verhoeff_check_digit("12345").unwrap(), 1)
  assert_true(verhoeff_check_digit("12a") is None)
}

///|
test "damm validates known numbers" {
  assert_true(damm_valid("5724"))
  assert_false(damm_valid("5723"))
  assert_false(damm_valid(""))
}

///|
test "damm check digit matches the reference vector" {
  assert_eq(damm_check_digit("572").unwrap(), 4)
  assert_true(damm_check_digit("1234a") is None)
}

///|
test "detect_brand recognises the major networks" {
  assert_eq(detect_brand("4111111111111111").to_string(), "visa")
  assert_eq(detect_brand("5555555555554444").to_string(), "mastercard")
  assert_eq(detect_brand("2221000000000009").to_string(), "mastercard")
  assert_eq(detect_brand("378282246310005").to_string(), "amex")
  assert_eq(detect_brand("6011111111111117").to_string(), "discover")
  assert_eq(detect_brand("3530111333300000").to_string(), "jcb")
  assert_eq(detect_brand("30569309025904").to_string(), "diners-club")
  assert_eq(detect_brand("6200000000000005").to_string(), "unionpay")
  assert_eq(detect_brand("1234567890123456").to_string(), "unknown")
}

///|
test "detect_brand respects the overlapping ranges" {
  // 622126-622925 is Discover, the rest of the 62 space is UnionPay.
  assert_eq(detect_brand("6221260000000000").to_string(), "discover")
  assert_eq(detect_brand("6229250000000000").to_string(), "discover")
  assert_eq(detect_brand("6220000000000000").to_string(), "unionpay")
  assert_eq(detect_brand("6440000000000000").to_string(), "discover")
}

///|
test "card_valid accepts well-formed test numbers" {
  assert_true(card_valid("4111111111111111"))
  assert_true(card_valid("4242424242424242"))
  assert_true(card_valid("5555555555554444"))
  assert_true(card_valid("378282246310005"))
  assert_true(card_valid("371449635398431"))
  assert_true(card_valid("6011111111111117"))
  assert_true(card_valid("3530111333300000"))
  assert_true(card_valid("30569309025904"))
  assert_true(card_valid("6200000000000005"))
}

///|
test "card_valid rejects bad lengths and bad check digits" {
  assert_false(card_valid("4111111111111112"))
  assert_false(card_valid("41111111111111"))
  assert_false(card_valid("0000000000000000"))
  assert_false(card_valid("4111 1111 1111 1111"))
  assert_false(card_valid(""))
}

///|
test "iban validates the published examples" {
  assert_true(iban_valid("GB82WEST12345698765432"))
  assert_true(iban_valid("DE89370400440532013000"))
  assert_true(iban_valid("FR1420041010050500013M02606"))
  assert_true(iban_valid("NL91ABNA0417164300"))
}

///|
test "iban ignores spaces and case" {
  assert_true(iban_valid("gb82 west 1234 5698 7654 32"))
  assert_true(iban_valid("DE89 3704 0044 0532 0130 00"))
}

///|
test "iban rejects bad check digits and unknown countries" {
  assert_false(iban_valid("GB82WEST12345698765433"))
  assert_false(iban_valid("ZZ82WEST12345698765432"))
  assert_false(iban_valid("GB82WEST1234569876543"))
  assert_false(iban_valid(""))
}

///|
test "iban fields are extracted" {
  assert_eq(iban_country("GB82WEST12345698765432").unwrap(), "GB")
  assert_true(iban_country("12") is None)
  assert_eq(
    iban_format("GB82WEST12345698765432").unwrap(),
    "GB82 WEST 1234 5698 7654 32",
  )
  assert_true(iban_format("GB82WEST12345698765433") is None)
  assert_eq(iban_bban("GB82WEST12345698765432").unwrap(), "WEST12345698765432")
}

///|
test "card_format groups digits in fours" {
  assert_eq(card_format("378282246310005").unwrap(), "3782 8224 6310 005")
  assert_eq(card_format("4111111111111111").unwrap(), "4111 1111 1111 1111")
  assert_eq(card_format("12345").unwrap(), "1234 5")
  assert_true(card_format("4111 1111") is None)
  assert_true(card_format("") is None)
}

///|
test "iban check digits are generated correctly" {
  assert_eq(iban_check_digits("GB", "WEST12345698765432").unwrap(), "82")
  assert_eq(iban_check_digits("DE", "370400440532013000").unwrap(), "89")
  assert_eq(iban_check_digits("FR", "20041010050500013M02606").unwrap(), "14")
  // Lowercase and spaces in the country/BBAN are normalised away.
  assert_eq(iban_check_digits("gb", "west 1234 5698 7654 32").unwrap(), "82")
}

///|
test "iban check digits reject bad input" {
  assert_true(iban_check_digits("ZZ", "WEST12345698765432") is None)
  assert_true(iban_check_digits("G", "WEST12345698765432") is None)
  assert_true(iban_check_digits("GB", "") is None)
  // Wrong total length for the country.
  assert_true(iban_check_digits("GB", "TOOSHORT") is None)
}

///|
test "iban_assemble round-trips with iban_valid" {
  assert_eq(
    iban_assemble("GB", "WEST12345698765432").unwrap(),
    "GB82WEST12345698765432",
  )
  assert_eq(
    iban_assemble("DE", "370400440532013000").unwrap(),
    "DE89370400440532013000",
  )
  assert_true(iban_assemble("ZZ", "WEST12345698765432") is None)
}

///|
test "imei validates the published example" {
  assert_true(imei_valid("490154203237518"))
  assert_false(imei_valid("490154203237519"))
  assert_false(imei_valid("49015420323751"))
  assert_false(imei_valid("4901542032375180"))
}

///|
test "imei fields are extracted" {
  assert_eq(imei_check_digit("49015420323751").unwrap(), 8)
  assert_true(imei_check_digit("4901542032375") is None)
  assert_eq(imei_tac("490154203237518").unwrap(), "49015420")
  assert_eq(imei_serial("490154203237518").unwrap(), "323751")
}

///|
test "cn_id validates published examples" {
  assert_true(cn_id_valid("11010519491231002X"))
  assert_true(cn_id_valid("440524188001010014"))
  // Lowercase x is accepted for the check character.
  assert_true(cn_id_valid("11010519491231002x"))
  assert_false(cn_id_valid("110105194912310021"))
  assert_false(cn_id_valid("1101051949123100"))
}

///|
test "cn_id rejects implausible birth dates" {
  // Month 13 is out of range.
  assert_false(cn_id_valid("11010519491331002X"))
  // Month 00 and day 00 are out of range.
  assert_false(cn_id_valid("11010519490031002X"))
}

///|
test "cn_id extracts region and birth date" {
  assert_eq(cn_id_region("11010519491231002X").unwrap(), "110105")
  assert_eq(cn_id_birthdate("11010519491231002X").unwrap(), "19491231")
  assert_true(cn_id_region("110105194912310021") is None)
}

///|
test "cn_id check character is generated" {
  assert_eq(cn_id_check_char("11010519491231002").unwrap(), "X")
  assert_eq(cn_id_check_char("44052418800101001").unwrap(), "4")
  assert_true(cn_id_check_char("1101051949123100") is None)
  assert_true(cn_id_check_char("1101051949123100A") is None)
}

///|
test "aadhaar validates the published example" {
  assert_true(aadhaar_valid("234123412346"))
  assert_false(aadhaar_valid("234123412347"))
  assert_false(aadhaar_valid("23412341234"))
  assert_false(aadhaar_valid("2341234123465"))
  // Non-digits are rejected outright.
  assert_false(aadhaar_valid("23412341234X"))
}

///|
test "aadhaar check digit is generated" {
  assert_eq(aadhaar_check_digit("23412341234").unwrap(), 6)
  assert_true(aadhaar_check_digit("2341234123") is None)
  assert_true(aadhaar_check_digit("2341234123X") is None)
}

///|
test "vin validates the NHTSA published example" {
  assert_true(vin_valid("1M8GDM9AXKP042788"))
  assert_true(vin_valid("1HGCM82633A004352"))
  // Lowercase input is accepted.
  assert_true(vin_valid("1m8gdm9axkp042788"))
  // The check character is wrong here.
  assert_false(vin_valid("1M8GDM9A1KP042788"))
  assert_false(vin_valid("1M8GDM9AXKP04278"))
}

///|
test "vin rejects the letters I, O and Q" {
  assert_false(vin_valid("1M8GDM9AXKPO42788"))
  assert_false(vin_valid("1M8GDM9AXKPI42788"))
  assert_false(vin_valid("1M8GDM9AXKPQ42788"))
}

///|
test "vin check character and fields" {
  assert_eq(vin_check_char("1M8GDM9AXKP042788").unwrap(), "X")
  assert_eq(vin_wmi("1M8GDM9AXKP042788").unwrap(), "1M8")
  assert_eq(vin_vis("1M8GDM9AXKP042788").unwrap(), "KP042788")
  assert_true(vin_wmi("1M8GDM9A1KP042788") is None)
}

///|
test "isin validates published examples" {
  // AU0000XVGZA3 is the worked example in ISO 6166 itself.
  assert_true(isin_valid("AU0000XVGZA3"))
  assert_true(isin_valid("US0378331005"))
  assert_true(isin_valid("GB0002634946"))
  // Lowercase input is accepted.
  assert_true(isin_valid("us0378331005"))
  assert_false(isin_valid("US0378331004"))
  assert_false(isin_valid("US037833100"))
  // The first two characters must be letters.
  assert_false(isin_valid("120378331005"))
}

///|
test "isin check digit and country are extracted" {
  assert_eq(isin_check_digit("US037833100").unwrap(), 5)
  assert_eq(isin_check_digit("AU0000XVGZA").unwrap(), 3)
  assert_true(isin_check_digit("US03783310") is None)
  assert_eq(isin_country("US0378331005").unwrap(), "US")
  assert_eq(isin_country("us0378331005").unwrap(), "US")
  assert_true(isin_country("1S0378331005") is None)
}

///|
test "lei validates examples registered with GLEIF" {
  // Ubisecure Oy, Bloomberg Finance L.P., Sanofi, Lloyds Bank Corporate Markets.
  assert_true(lei_valid("529900T8BM49AURSDO55"))
  assert_true(lei_valid("5493001KJTIIGC8Y1R12"))
  assert_true(lei_valid("549300E9PC51EN656011"))
  assert_true(lei_valid("213800MBWEIJDM5CU638"))
  // Lowercase input is accepted.
  assert_true(lei_valid("529900t8bm49aursdo55"))
  assert_false(lei_valid("529900T8BM49AURSDO56"))
  assert_false(lei_valid("529900T8BM49AURSDO5"))
  assert_false(lei_valid("529900T8BM49AURSDO5!"))
}

///|
test "lei check digits and LOU are extracted" {
  assert_eq(lei_check_digits("529900T8BM49AURSDO").unwrap(), "55")
  assert_eq(lei_check_digits("5493001KJTIIGC8Y1R").unwrap(), "12")
  // A remainder of zero wraps to 98, the largest pair the scheme can produce.
  assert_eq(lei_check_digits("648800CXUUNZXUJW1T").unwrap(), "98")
  assert_true(lei_check_digits("529900T8BM49AURSD") is None)
  assert_true(lei_check_digits("529900T8BM49AURSD!") is None)
  assert_eq(lei_lou("529900T8BM49AURSDO55").unwrap(), "5299")
  assert_true(lei_lou("529900T8BM49AURSDO56") is None)
}
