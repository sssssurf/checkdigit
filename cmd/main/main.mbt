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
