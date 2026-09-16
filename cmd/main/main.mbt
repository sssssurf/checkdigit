// A small command-line front end for the checkdigit library.
// Every subcommand prints a report and, where the input carries a check
// digit, the digit that would make it correct.

///|
fn main {
  let args = @env.args()
  if args.length() < 3 {
    print_usage()
    return
  }
  let sub = args[1]
  let input = args[2]
  match sub {
    "luhn" => run_luhn(input)
    "verhoeff" => run_verhoeff(input)
    "damm" => run_damm(input)
    "card" => run_card(input)
    "iban" => run_iban(input)
    "imei" => run_imei(input)
    "cnid" => run_cn_id(input)
    "aadhaar" => run_aadhaar(input)
    "vin" => run_vin(input)
    "isin" => run_isin(input)
    "lei" => run_lei(input)
    "uscc" => run_uscc(input)
    "cpf" => run_cpf(input)
    "cnpj" => run_cnpj(input)
    "bsn" => run_bsn(input)
    "cf" => run_cf(input)
    _ => print_usage()
  }
}

///|
fn print_usage() -> Unit {
  println("checkdigit — check digits and identifier validation for MoonBit")
  println("")
  println("usage:")
  println("  checkdigit luhn     <digits>")
  println("  checkdigit verhoeff <digits>")
  println("  checkdigit damm     <digits>")
  println("  checkdigit card     <number>")
  println("  checkdigit iban     <iban>")
  println("  checkdigit imei     <imei>")
  println("  checkdigit cnid     <resident id number>")
  println("  checkdigit aadhaar  <12 digits>")
  println("  checkdigit vin      <vin>")
  println("  checkdigit isin     <isin>")
  println("  checkdigit lei      <lei>")
  println("  checkdigit uscc     <unified social credit id>")
  println("  checkdigit cpf      <cpf>")
  println("  checkdigit cnpj     <cnpj>")
  println("  checkdigit bsn      <8 or 9 digits>")
  println("  checkdigit cf       <codice fiscale>")
}

///|
fn show_opt(label : String, v : String?) -> Unit {
  match v {
    Some(x) => println("\{label}: \{x}")
    None => println("\{label}: (none)")
  }
}

///|
fn show_digit(label : String, v : Int?) -> Unit {
  match v {
    Some(x) => println("\{label}: \{x}")
    None => println("\{label}: (not computable)")
  }
}

///|
fn verdict(ok : Bool) -> String {
  if ok {
    "valid"
  } else {
    "invalid"
  }
}

///|
fn run_luhn(s : String) -> Unit {
  println("luhn: \{s}")
  println("status: \{verdict(@checkdigit.luhn_valid(s))}")
  show_digit("check digit (append to input)", @checkdigit.luhn_check_digit(s))
}

///|
fn run_verhoeff(s : String) -> Unit {
  println("verhoeff: \{s}")
  println("status: \{verdict(@checkdigit.verhoeff_valid(s))}")
  show_digit(
    "check digit (append to input)",
    @checkdigit.verhoeff_check_digit(s),
  )
}

///|
fn run_damm(s : String) -> Unit {
  println("damm: \{s}")
  println("status: \{verdict(@checkdigit.damm_valid(s))}")
  show_digit("check digit (append to input)", @checkdigit.damm_check_digit(s))
}

///|
fn run_card(s : String) -> Unit {
  println("card: \{s}")
  println("brand: \{@checkdigit.detect_brand(s).to_string()}")
  println("status: \{verdict(@checkdigit.card_valid(s))}")
}

///|
fn run_iban(s : String) -> Unit {
  println("iban: \{s}")
  show_opt("country", @checkdigit.iban_country(s))
  show_opt("formatted", @checkdigit.iban_format(s))
  println("status: \{verdict(@checkdigit.iban_valid(s))}")
}

///|
fn run_imei(s : String) -> Unit {
  println("imei: \{s}")
  match (@checkdigit.imei_tac(s), @checkdigit.imei_serial(s)) {
    (Some(tac), Some(serial)) => {
      println("tac: \{tac}")
      println("serial: \{serial}")
      // The check digit covers the 14 digits of TAC plus serial.
      show_digit("check digit", @checkdigit.imei_check_digit(tac + serial))
    }
    _ => {
      println("tac: (none)")
      println("serial: (none)")
    }
  }
  println("status: \{verdict(@checkdigit.imei_valid(s))}")
}

///|
/// The first `n` characters of `s`, or None when it is shorter. Used to pull
/// the payload out of a complete identifier so the expected check character
/// can be shown alongside the one that is present.
fn take(s : String, n : Int) -> String? {
  let buf = StringBuilder()
  let mut seen = 0
  for c in s {
    if seen < n {
      buf.write_char(c)
    }
    seen = seen + 1
  }
  if seen < n {
    None
  } else {
    Some(buf.to_string())
  }
}

///|
fn show_check(label : String, body : String?, f : (String) -> String?) -> Unit {
  match body {
    Some(b) => show_opt(label, f(b))
    None => show_opt(label, None)
  }
}

///|
fn run_cn_id(s : String) -> Unit {
  println("cnid: \{s}")
  show_opt("region", @checkdigit.cn_id_region(s))
  show_opt("birth date", @checkdigit.cn_id_birthdate(s))
  show_check(
    "expected check character",
    take(s, 17),
    @checkdigit.cn_id_check_char,
  )
  println("status: \{verdict(@checkdigit.cn_id_valid(s))}")
}

///|
fn run_aadhaar(s : String) -> Unit {
  println("aadhaar: \{s}")
  match take(s, 11) {
    Some(body) =>
      show_digit("expected check digit", @checkdigit.aadhaar_check_digit(body))
    None => show_digit("expected check digit", None)
  }
  println("status: \{verdict(@checkdigit.aadhaar_valid(s))}")
}

///|
fn run_vin(s : String) -> Unit {
  println("vin: \{s}")
  show_opt("wmi", @checkdigit.vin_wmi(s))
  show_opt("vis", @checkdigit.vin_vis(s))
  // The check character sits at position nine, so the whole VIN is the payload.
  show_check(
    "expected check character",
    take(s, 17),
    @checkdigit.vin_check_char,
  )
  println("status: \{verdict(@checkdigit.vin_valid(s))}")
}

///|
fn run_isin(s : String) -> Unit {
  println("isin: \{s}")
  show_opt("country", @checkdigit.isin_country(s))
  match take(s, 11) {
    Some(body) =>
      show_digit("expected check digit", @checkdigit.isin_check_digit(body))
    None => show_digit("expected check digit", None)
  }
  println("status: \{verdict(@checkdigit.isin_valid(s))}")
}

///|
fn run_lei(s : String) -> Unit {
  println("lei: \{s}")
  show_opt("lou", @checkdigit.lei_lou(s))
  show_check("expected check digits", take(s, 18), @checkdigit.lei_check_digits)
  println("status: \{verdict(@checkdigit.lei_valid(s))}")
}

///|
fn run_uscc(s : String) -> Unit {
  println("uscc: \{s}")
  show_opt("division", @checkdigit.uscc_division(s))
  show_check(
    "expected check character",
    take(s, 17),
    @checkdigit.uscc_check_char,
  )
  println("status: \{verdict(@checkdigit.uscc_valid(s))}")
}

///|
fn run_cpf(s : String) -> Unit {
  println("cpf: \{s}")
  show_opt("formatted", @checkdigit.cpf_format(s))
  show_check("expected check digits", take(s, 9), @checkdigit.cpf_check_digits)
  println("status: \{verdict(@checkdigit.cpf_valid(s))}")
}

///|
fn run_cnpj(s : String) -> Unit {
  println("cnpj: \{s}")
  show_opt("formatted", @checkdigit.cnpj_format(s))
  show_check(
    "expected check digits",
    take(s, 12),
    @checkdigit.cnpj_check_digits,
  )
  println("status: \{verdict(@checkdigit.cnpj_valid(s))}")
}

///|
fn run_bsn(s : String) -> Unit {
  println("bsn: \{s}")
  match take(s, 8) {
    Some(body) =>
      show_digit("expected check digit", @checkdigit.bsn_check_digit(body))
    None => show_digit("expected check digit", None)
  }
  println("status: \{verdict(@checkdigit.bsn_valid(s))}")
}

///|
fn run_cf(s : String) -> Unit {
  println("cf: \{s}")
  show_check("expected check character", take(s, 15), @checkdigit.cf_check_char)
  println("status: \{verdict(@checkdigit.cf_valid(s))}")
}
