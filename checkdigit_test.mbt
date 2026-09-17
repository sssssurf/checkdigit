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

///|
test "uscc validates registered identifiers" {
  // Alibaba (China) Co., Ltd., from its published business registration.
  assert_true(uscc_valid("91330100799655058B"))
  assert_true(uscc_valid("91350100M000100Y43"))
  // Lowercase input is accepted.
  assert_true(uscc_valid("91330100799655058b"))
  assert_false(uscc_valid("91330100799655058C"))
  assert_false(uscc_valid("91330100799655058"))
  assert_false(uscc_valid("91330100799655058BB"))
}

///|
test "uscc rejects the five letters outside the code set" {
  // I, O, S, V and Z are left out so they cannot be read as 1, 0, 5, U and 2.
  assert_false(uscc_valid("I1330100799655058B"))
  assert_false(uscc_valid("O1330100799655058B"))
  assert_false(uscc_valid("S1330100799655058B"))
  assert_false(uscc_valid("V1330100799655058B"))
  assert_false(uscc_valid("Z1330100799655058B"))
  // A control: the same slot with a character that is in neither set.
  assert_false(uscc_valid("!1330100799655058B"))
}

///|
test "uscc check character and division are extracted" {
  assert_eq(uscc_check_char("91330100799655058").unwrap(), "B")
  assert_true(uscc_check_char("9133010079965505") is None)
  assert_eq(uscc_division("91330100799655058B").unwrap(), "330100")
  assert_true(uscc_division("91330100799655058C") is None)
}

///|
test "cpf validates published examples" {
  assert_true(cpf_valid("11144477735"))
  assert_true(cpf_valid("52998224725"))
  assert_false(cpf_valid("11144477736"))
  assert_false(cpf_valid("1114447773"))
  assert_false(cpf_valid("111444777350"))
  assert_false(cpf_valid("1114447773a"))
  // Punctuation is not accepted, unlike IBAN.
  assert_false(cpf_valid("111.444.777-35"))
}

///|
test "cpf rejects repdigits" {
  assert_false(cpf_valid("00000000000"))
  assert_false(cpf_valid("11111111111"))
  assert_false(cpf_valid("99999999999"))
}

///|
test "cpf check digits and formatting" {
  assert_eq(cpf_check_digits("111444777").unwrap(), "35")
  assert_eq(cpf_check_digits("529982247").unwrap(), "25")
  assert_true(cpf_check_digits("11144477") is None)
  assert_true(cpf_check_digits("11144477a") is None)
  assert_eq(cpf_format("11144477735").unwrap(), "111.444.777-35")
  assert_true(cpf_format("1114447773") is None)
}

///|
test "cnpj validates published examples" {
  assert_true(cnpj_valid("11222333000181"))
  assert_true(cnpj_valid("11444777000161"))
  assert_false(cnpj_valid("11222333000182"))
  assert_false(cnpj_valid("1122233300018"))
  assert_false(cnpj_valid("112223330001811"))
  assert_false(cnpj_valid("11.222.333/0001-81"))
}

///|
test "cnpj rejects repdigits" {
  assert_false(cnpj_valid("00000000000000"))
  assert_false(cnpj_valid("11111111111111"))
}

///|
test "cnpj check digits and formatting" {
  assert_eq(cnpj_check_digits("112223330001").unwrap(), "81")
  assert_eq(cnpj_check_digits("114447770001").unwrap(), "61")
  assert_true(cnpj_check_digits("11222333000") is None)
  assert_true(cnpj_check_digits("11222333000a") is None)
  assert_eq(cnpj_format("11222333000181").unwrap(), "11.222.333/0001-81")
  assert_true(cnpj_format("1122233300018") is None)
}

///|
test "bsn passes the eleven test" {
  assert_true(bsn_valid("111222333"))
  assert_true(bsn_valid("123456782"))
  assert_false(bsn_valid("111222334"))
  assert_false(bsn_valid("11122233"))
  assert_false(bsn_valid("1112223334"))
  assert_false(bsn_valid("11122233a"))
}

///|
test "bsn accepts the eight-digit form and rejects all zeroes" {
  // Older numbers were recorded without the leading zero.
  assert_true(bsn_valid("10000008"))
  assert_true(bsn_valid("010000008"))
  assert_false(bsn_valid("000000000"))
  assert_false(bsn_valid("00000000"))
}

///|
test "bsn check digit is generated" {
  assert_eq(bsn_check_digit("11122233").unwrap(), 3)
  assert_eq(bsn_check_digit("12345678").unwrap(), 2)
  assert_true(bsn_check_digit("1112223") is None)
  // These eight digits would need a ninth of ten, which is not a digit.
  assert_true(bsn_check_digit("10000006") is None)
}

///|
test "codice fiscale validates published examples" {
  assert_true(cf_valid("MRNLCU00A01H501J"))
  assert_true(cf_valid("RSSMRA80A01A952F"))
  assert_true(cf_valid("MRNLCU00A01Z100P"))
  assert_true(cf_valid("RSSMRA90P50Z258M"))
  // Lowercase input is accepted.
  assert_true(cf_valid("mrnlcu00a01h501j"))
  assert_false(cf_valid("MRNLCU00A01H501K"))
  assert_false(cf_valid("MRNLCU00A01H501"))
}

///|
test "codice fiscale accepts omocodia substitutions" {
  // A numeric field may hold one of ten letters when two people would
  // otherwise share a code.
  assert_true(cf_valid("MRNLCULLALMH501A"))
  // Z is not one of those ten, so it cannot stand in a numeric field.
  assert_false(cf_valid("MRNLCUZZAZAH501J"))
}

///|
test "codice fiscale rejects a month letter outside the twelve" {
  assert_false(cf_valid("MRNLCU00F01H501J"))
  assert_false(cf_valid("MRNLCU00G01H501J"))
}

///|
test "codice fiscale check character is generated" {
  assert_eq(cf_check_char("MRNLCU00A01H501").unwrap(), "J")
  assert_eq(cf_check_char("RSSMRA80A01A952").unwrap(), "F")
  assert_true(cf_check_char("MRNLCU00A01H50") is None)
  assert_true(cf_check_char("MRNLCU00A01H50!") is None)
}

///|
test "cn_id rejects a tampered body digit" {
  // Flipping a digit in the region or sequence changes the expected check.
  assert_false(cn_id_valid("11010519491231012X"))
  assert_false(cn_id_valid("11010619491231002X"))
  assert_false(cn_id_valid("11010519491231003X"))
}

///|
test "cn_id rejects wrong lengths and non-digit bodies" {
  assert_false(cn_id_valid(""))
  assert_false(cn_id_valid("11010519491231002"))
  assert_false(cn_id_valid("11010519491231002XX"))
  assert_false(cn_id_valid("1101051949123100 2X"))
  assert_false(cn_id_valid("11010519491231002-"))
  assert_false(cn_id_valid("11010519491231A02X"))
  // A full-width digit must not be mistaken for its ASCII counterpart.
  assert_false(cn_id_valid("11010519491231002０"))
}

///|
test "cn_id birth year bounds are inclusive" {
  // 1799 is one below the accepted lower bound, 2200 one above the top.
  assert_false(cn_id_valid("110105179912310024"))
  assert_false(cn_id_valid("110105220001010022"))
  // The bounds themselves are accepted, provided the check character agrees.
  assert_true(cn_id_valid("820000180001010010"))
  assert_true(cn_id_valid("82000021991231001X"))
}

///|
test "cn_id accepts dates that are plausible but impossible" {
  // Documented limitation: month lengths and leap years are not modelled, so
  // 31 February passes as long as the check character agrees.
  assert_true(cn_id_valid("110105194902310026"))
}

///|
test "cn_id check character agrees with the validator" {
  // Whatever the generator produces must be accepted by the validator. That
  // round-trip is what makes the pair usable for building test data.
  let prefixes = [
    "11010519491231002", "44052418800101001", "31010120000229123", "50010319991231456",
    "82000018000101001",
  ]
  for p in prefixes {
    let c = cn_id_check_char(p).unwrap()
    assert_true(cn_id_valid(p + c))
    assert_true(cn_id_valid(p + c.to_lower()))
  }
}
