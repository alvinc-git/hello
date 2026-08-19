use std::env;

const PROGRAM_NAME: &str = "hello";
const PROGRAM_VERSION: &str = "1.0.0";

fn print_usage() {
    println!("Usage: {} [OPTION]", PROGRAM_NAME);
    println!("Print 'Hello, World!' to standard output.\n");
    println!("  -h, --help         display this help and exit");
    println!("  -v, -V, --version  output version information and exit");
}

fn print_version() {
    println!("{} version {}", PROGRAM_NAME, PROGRAM_VERSION);
}

fn main() {
    let args: Vec<String> = env::args().collect();
    for arg in &args[1..] {
        match arg.as_str() {
            "-h" | "--help" => {
                print_usage();
                return;
            }
            "-v" | "-V" | "--version" => {
                print_version();
                return;
            }
            _ => {}
        }
    }
    println!("Hello, World!");
}
