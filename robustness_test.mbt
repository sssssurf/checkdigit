// Robustness matrix: drive every public entry point with hostile input.
//
// The library promises total functions - "invalid input returns false or None,
// never raises or panics" (项目申报书.md). A panic or abort inside a test fails
// the run, so simply calling every entry point with malformed input is a real
// assertion about that promise.
//
// Stage 1 (this file) only checks: no crash, and the *valid* family returns
// false. Tightening the extraction family to "must return None" is a follow-up
// decision, because some of those are documented as lenient.

///|
/// Inputs every function in the public API has to survive. These are the shapes
/// that turn up in real form data and batch imports.
let hostile_inputs : Array[String] = [
  "", // empty
   " ", // one space
   "   ", // all whitespace
   "\t", "\n", "-", // punctuation only
   "--", "!@#$%^&*()", "0", // too short for everything
   "0000000000000000000000000000000000000000", // all zeroes
   "9999999999999999999999999999999999999999", "1234567890123456789012345678901234567890", // far longer than any real id
   "１２３４５６７８９０", // full-width digits
   "١٢٣٤٥٦٧٨٩٠", // Arabic-Indic digits
   "abcdefghij", "ABCDEFGHIJ", "11010519491231002\u0000", // trailing NUL
   "110105 19491231002X", // inner space
   "11010519491231002x", // lowercase check char
   " 11010519491231002X ", // surrounding whitespace
   "11010519491231002X.", // trailing junk
]

///|
test "no validator panics on hostile input" {
  for s in hostile_inputs {
    // Returning a value at all is the assertion. A panic aborts the test run.
    let _ = aadhaar_valid(s)
    let _ = bsn_valid(s)
    let _ = card_valid(s)
    let _ = cf_valid(s)
    let _ = cn_id_valid(s)
    let _ = cnpj_valid(s)
    let _ = cpf_valid(s)
    let _ = damm_valid(s)
    let _ = iban_valid(s)
    let _ = imei_valid(s)
    let _ = isin_valid(s)
    let _ = lei_valid(s)
    let _ = luhn_valid(s)
    let _ = uscc_valid(s)
    let _ = verhoeff_valid(s)
    let _ = vin_valid(s)
  }
}

///|
test "no check-digit generator panics on hostile input" {
  for s in hostile_inputs {
    let _ = aadhaar_check_digit(s)
    let _ = bsn_check_digit(s)
    let _ = cf_check_char(s)
    let _ = cn_id_check_char(s)
    let _ = cnpj_check_digits(s)
    let _ = cpf_check_digits(s)
    let _ = damm_check_digit(s)
    let _ = imei_check_digit(s)
    let _ = isin_check_digit(s)
    let _ = lei_check_digits(s)
    let _ = luhn_check_digit(s)
    let _ = uscc_check_char(s)
    let _ = verhoeff_check_digit(s)
    let _ = vin_check_char(s)
  }
}

///|
test "no extractor panics on hostile input" {
  for s in hostile_inputs {
    let _ = cn_id_birthdate(s)
    let _ = cn_id_region(s)
    let _ = iban_bban(s)
    let _ = iban_country(s)
    let _ = iban_format(s)
    let _ = iban_normalize(s)
    let _ = imei_serial(s)
    let _ = imei_tac(s)
    let _ = isin_country(s)
    let _ = lei_lou(s)
    let _ = card_format(s)
    let _ = cnpj_format(s)
    let _ = cpf_format(s)
    let _ = uscc_division(s)
    let _ = vin_vis(s)
    let _ = vin_wmi(s)
    let _ = detect_brand(s)
  }
}

///|
test "no iban helper panics on hostile input" {
  for s in hostile_inputs {
    let _ = iban_expected_length(s)
    // Both arguments are hostile at once here.
    let _ = iban_assemble(s, s)
    let _ = iban_check_digits(s, s)
  }
}

///|
test "validators reject empty and whitespace-only input" {
  let bad = ["", " ", "   ", "\t", "\n", "\r\n"]
  for s in bad {
    assert_false(aadhaar_valid(s))
    assert_false(bsn_valid(s))
    assert_false(card_valid(s))
    assert_false(cf_valid(s))
    assert_false(cn_id_valid(s))
    assert_false(cnpj_valid(s))
    assert_false(cpf_valid(s))
    assert_false(damm_valid(s))
    assert_false(iban_valid(s))
    assert_false(imei_valid(s))
    assert_false(isin_valid(s))
    assert_false(lei_valid(s))
    assert_false(luhn_valid(s))
    assert_false(uscc_valid(s))
    assert_false(verhoeff_valid(s))
    assert_false(vin_valid(s))
  }
}

///|
test "validators reject punctuation and letters" {
  let bad = ["-", "--", "!@#$%^&*()", "abcdefghij", "ABCDEFGHIJ"]
  for s in bad {
    assert_false(aadhaar_valid(s))
    assert_false(bsn_valid(s))
    assert_false(card_valid(s))
    assert_false(cf_valid(s))
    assert_false(cn_id_valid(s))
    assert_false(cnpj_valid(s))
    assert_false(cpf_valid(s))
    assert_false(damm_valid(s))
    assert_false(iban_valid(s))
    assert_false(imei_valid(s))
    assert_false(isin_valid(s))
    assert_false(lei_valid(s))
    assert_false(luhn_valid(s))
    assert_false(uscc_valid(s))
    assert_false(verhoeff_valid(s))
    assert_false(vin_valid(s))
  }
}
