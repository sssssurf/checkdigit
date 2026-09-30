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
    let _ = @checkdigit.aadhaar_valid(s)
    let _ = @checkdigit.bsn_valid(s)
    let _ = @checkdigit.card_valid(s)
    let _ = @checkdigit.cf_valid(s)
    let _ = @checkdigit.cn_id_valid(s)
    let _ = @checkdigit.cnpj_valid(s)
    let _ = @checkdigit.cpf_valid(s)
    let _ = @checkdigit.damm_valid(s)
    let _ = @checkdigit.iban_valid(s)
    let _ = @checkdigit.imei_valid(s)
    let _ = @checkdigit.isin_valid(s)
    let _ = @checkdigit.lei_valid(s)
    let _ = @checkdigit.luhn_valid(s)
    let _ = @checkdigit.uscc_valid(s)
    let _ = @checkdigit.verhoeff_valid(s)
    let _ = @checkdigit.vin_valid(s)
  }
}

///|
test "no check-digit generator panics on hostile input" {
  for s in hostile_inputs {
    let _ = @checkdigit.aadhaar_check_digit(s)
    let _ = @checkdigit.bsn_check_digit(s)
    let _ = @checkdigit.cf_check_char(s)
    let _ = @checkdigit.cn_id_check_char(s)
    let _ = @checkdigit.cnpj_check_digits(s)
    let _ = @checkdigit.cpf_check_digits(s)
    let _ = @checkdigit.damm_check_digit(s)
    let _ = @checkdigit.imei_check_digit(s)
    let _ = @checkdigit.isin_check_digit(s)
    let _ = @checkdigit.lei_check_digits(s)
    let _ = @checkdigit.luhn_check_digit(s)
    let _ = @checkdigit.uscc_check_char(s)
    let _ = @checkdigit.verhoeff_check_digit(s)
    let _ = @checkdigit.vin_check_char(s)
  }
}

///|
test "no extractor panics on hostile input" {
  for s in hostile_inputs {
    let _ = @checkdigit.cn_id_birthdate(s)
    let _ = @checkdigit.cn_id_region(s)
    let _ = @checkdigit.iban_bban(s)
    let _ = @checkdigit.iban_country(s)
    let _ = @checkdigit.iban_format(s)
    let _ = @checkdigit.iban_normalize(s)
    let _ = @checkdigit.imei_serial(s)
    let _ = @checkdigit.imei_tac(s)
    let _ = @checkdigit.isin_country(s)
    let _ = @checkdigit.lei_lou(s)
    let _ = @checkdigit.card_format(s)
    let _ = @checkdigit.cnpj_format(s)
    let _ = @checkdigit.cpf_format(s)
    let _ = @checkdigit.uscc_division(s)
    let _ = @checkdigit.vin_vis(s)
    let _ = @checkdigit.vin_wmi(s)
    let _ = @checkdigit.detect_brand(s)
  }
}

///|
test "no iban helper panics on hostile input" {
  for s in hostile_inputs {
    let _ = @checkdigit.iban_expected_length(s)
    // Both arguments are hostile at once here.
    let _ = @checkdigit.iban_assemble(s, s)
    let _ = @checkdigit.iban_check_digits(s, s)
  }
}

///|
test "validators reject empty and whitespace-only input" {
  let bad = ["", " ", "   ", "\t", "\n", "\r\n"]
  for s in bad {
    assert_false(@checkdigit.aadhaar_valid(s))
    assert_false(@checkdigit.bsn_valid(s))
    assert_false(@checkdigit.card_valid(s))
    assert_false(@checkdigit.cf_valid(s))
    assert_false(@checkdigit.cn_id_valid(s))
    assert_false(@checkdigit.cnpj_valid(s))
    assert_false(@checkdigit.cpf_valid(s))
    assert_false(@checkdigit.damm_valid(s))
    assert_false(@checkdigit.iban_valid(s))
    assert_false(@checkdigit.imei_valid(s))
    assert_false(@checkdigit.isin_valid(s))
    assert_false(@checkdigit.lei_valid(s))
    assert_false(@checkdigit.luhn_valid(s))
    assert_false(@checkdigit.uscc_valid(s))
    assert_false(@checkdigit.verhoeff_valid(s))
    assert_false(@checkdigit.vin_valid(s))
  }
}

///|
test "validators reject punctuation and letters" {
  let bad = ["-", "--", "!@#$%^&*()", "abcdefghij", "ABCDEFGHIJ"]
  for s in bad {
    assert_false(@checkdigit.aadhaar_valid(s))
    assert_false(@checkdigit.bsn_valid(s))
    assert_false(@checkdigit.card_valid(s))
    assert_false(@checkdigit.cf_valid(s))
    assert_false(@checkdigit.cn_id_valid(s))
    assert_false(@checkdigit.cnpj_valid(s))
    assert_false(@checkdigit.cpf_valid(s))
    assert_false(@checkdigit.damm_valid(s))
    assert_false(@checkdigit.iban_valid(s))
    assert_false(@checkdigit.imei_valid(s))
    assert_false(@checkdigit.isin_valid(s))
    assert_false(@checkdigit.lei_valid(s))
    assert_false(@checkdigit.luhn_valid(s))
    assert_false(@checkdigit.uscc_valid(s))
    assert_false(@checkdigit.verhoeff_valid(s))
    assert_false(@checkdigit.vin_valid(s))
  }
}
