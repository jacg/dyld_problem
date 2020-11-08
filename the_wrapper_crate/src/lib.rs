#![allow(nonstandard_style)]

include!(concat!(env!("OUT_DIR"), "/bindings.rs"));

#[cfg(test)]
mod test {

    use super::*;

    #[test]
    fn does_not_crash() {
        let input = 6;
        let result = unsafe { the_C_function(input) };
        assert_eq!(result, 3 * input);
    }
}
