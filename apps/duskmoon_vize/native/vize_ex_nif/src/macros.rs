macro_rules! term_map {
    ($env:expr, { $($key:expr => $value:expr),+ $(,)? }) => {
        rustler::Term::map_from_arrays(
            $env,
            &[$($key.encode($env)),+],
            &[$($value.encode($env)),+],
        )
        .unwrap()
    };
}
