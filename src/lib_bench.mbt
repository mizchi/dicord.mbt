///|
test "encode_query benchmark" (b : @bench.T) {
  let query = [
    ("limit", "100"),
    ("after", "123456789"),
    ("before", "987654321"),
    ("around", "55555555"),
  ]
  b.bench(fn() { ignore(encode_query(query)) })
}
