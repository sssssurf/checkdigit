// demo.mbt — a runnable tour of the public API.
//
// This exists because the acceptance criteria ask for a runnable example, not
// just a README snippet: something a reviewer can execute end to end and compare
// against the recorded output in docs/reproducible-demo.md.
//
// Run it with:
//   moon run cmd/demo
//
// Every value printed here comes from the library itself. Nothing is hard-coded
// to make the output look right, so if a validator regresses this output changes.

///|
/// Print one labelled line.
fn show(label : String, value : String) -> Unit {
  println("\{label}: \{value}")
}

///|
/// Render an optional string, distinguishing "none" from an empty string.
fn show_opt(label : String, value : String?) -> Unit {
  match value {
    Some(v) => show(label, v)
    None => show(label, "(none)")
  }
}

///|
/// Render an optional integer.
fn show_int(label : String, value : Int?) -> Unit {
  match value {
    Some(v) => show(label, v.to_string())
    None => show(label, "(none)")
  }
}

///|
/// Render a boolean as the words used throughout the docs.
fn show_bool(label : String, value : Bool) -> Unit {
  show(label, if value { "valid" } else { "invalid" })
}

///|
/// A heading, so the output reads as one scroll.
fn heading(title : String) -> Unit {
  println("")
  println("== \{title} ==")
}

///|
fn main {
  println("checkdigit — validator tour")
  println("every line below is produced by the library at run time")

  heading("algorithms (payload only, no identifier semantics)")
  show_int("luhn_check_digit(7992739871)", @cd.luhn_check_digit("7992739871"))
  show_bool("luhn_valid(79927398713)", @cd.luhn_valid("79927398713"))
  show_bool("luhn_valid(79927398710)", @cd.luhn_valid("79927398710"))
  show_int("verhoeff_check_digit(236)", @cd.verhoeff_check_digit("236"))
  show_bool("verhoeff_valid(2363)", @cd.verhoeff_valid("2363"))
  show_int("damm_check_digit(572)", @cd.damm_check_digit("572"))
  show_bool("damm_valid(5724)", @cd.damm_valid("5724"))

  heading("payment cards")
  show(
    "detect_brand(4111111111111111)",
    @cd.detect_brand("4111111111111111").to_string(),
  )
  show(
    "detect_brand(378282246310005)",
    @cd.detect_brand("378282246310005").to_string(),
  )
  show_bool("card_valid(378282246310005)", @cd.card_valid("378282246310005"))
  show_opt("card_format(378282246310005)", @cd.card_format("378282246310005"))

  heading("IBAN")
  show_bool(
    "iban_valid(GB82 WEST 1234 5698 7654 32)",
    @cd.iban_valid("GB82 WEST 1234 5698 7654 32"),
  )
  show_opt("iban_country", @cd.iban_country("GB82WEST12345698765432"))
  show_opt("iban_bban", @cd.iban_bban("GB82WEST12345698765432"))
  show_opt("iban_format", @cd.iban_format("GB82WEST12345698765432"))
  show_opt(
    "iban_check_digits(GB, WEST...)",
    @cd.iban_check_digits("GB", "WEST12345698765432"),
  )
  show_opt(
    "iban_assemble(GB, WEST...)",
    @cd.iban_assemble("GB", "WEST12345698765432"),
  )
  match @cd.iban_expected_length("GB") {
    Some(n) => show("iban_expected_length(GB)", n.to_string())
    None => show("iban_expected_length(GB)", "(none)")
  }

  heading("device and identity numbers")
  show_opt("imei_tac(490154203237518)", @cd.imei_tac("490154203237518"))
  show_opt("imei_serial(490154203237518)", @cd.imei_serial("490154203237518"))
  show_int(
    "imei_check_digit(49015420323751)",
    @cd.imei_check_digit("49015420323751"),
  )
  show_bool(
    "cn_id_valid(11010519491231002X)",
    @cd.cn_id_valid("11010519491231002X"),
  )
  show_opt("cn_id_region", @cd.cn_id_region("11010519491231002X"))
  show_opt("cn_id_birthdate", @cd.cn_id_birthdate("11010519491231002X"))
  show_opt(
    "cn_id_check_char(11010519491231002)",
    @cd.cn_id_check_char("11010519491231002"),
  )
  show_bool("aadhaar_valid(234123412346)", @cd.aadhaar_valid("234123412346"))

  heading("securities and legal entities")
  show_bool("vin_valid(1M8GDM9AXKP042788)", @cd.vin_valid("1M8GDM9AXKP042788"))
  show_opt("vin_wmi", @cd.vin_wmi("1M8GDM9AXKP042788"))
  show_opt("vin_vis", @cd.vin_vis("1M8GDM9AXKP042788"))
  show_bool("isin_valid(US0378331005)", @cd.isin_valid("US0378331005"))
  show_opt("isin_country(US0378331005)", @cd.isin_country("US0378331005"))
  show_bool(
    "lei_valid(529900T8BM49AURSDO55)",
    @cd.lei_valid("529900T8BM49AURSDO55"),
  )
  show_opt("lei_lou(529900T8BM49AURSDO55)", @cd.lei_lou("529900T8BM49AURSDO55"))

  heading("jurisdiction-specific identifiers")
  show_bool(
    "uscc_valid(91350100M000100Y43)",
    @cd.uscc_valid("91350100M000100Y43"),
  )
  show_opt(
    "uscc_division(91350100M000100Y43)",
    @cd.uscc_division("91350100M000100Y43"),
  )
  show_bool("cpf_valid(11144477735)", @cd.cpf_valid("11144477735"))
  show_opt("cpf_format(11144477735)", @cd.cpf_format("11144477735"))
  show_bool("cnpj_valid(11222333000181)", @cd.cnpj_valid("11222333000181"))
  show_opt("cnpj_format(11222333000181)", @cd.cnpj_format("11222333000181"))
  show_bool("bsn_valid(111222333)", @cd.bsn_valid("111222333"))
  show_bool("cf_valid(RSSMRA85T10A562S)", @cd.cf_valid("RSSMRA85T10A562S"))

  heading("the totality promise: bad input never panics")
  let hostile = [
    "", " ", "not-a-number", "1234567890", "9999999999999999999999",
  ]
  for s in hostile {
    let luhn = if @cd.luhn_valid(s) { "true" } else { "false" }
    let cnid = if @cd.cn_id_valid(s) { "true" } else { "false" }
    let iban = if @cd.iban_valid(s) { "true" } else { "false" }
    println("  [\{s}] -> luhn=\{luhn} cnid=\{cnid} iban=\{iban}")
  }
  println("")
  println("done")
}
