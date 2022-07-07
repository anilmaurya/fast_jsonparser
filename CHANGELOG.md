# 0.6.0
* Fix performance on Ruby 3.0 [Issue #20](https://github.com/anilmaurya/fast_jsonparser/issues/20), thanks to [Watson1978](https://github.com/Watson1978)
# 0.5.0
* Handle concurrent use of the parser in [Issue #15](https://github.com/anilmaurya/fast_jsonparser/pull/15), thanks to [casperisfine](https://github.com/casperisfine)

# 0.4.0
* load_many accept batch_size parameter to parse documents larger than 1 MB in [PR #5](https://github.com/anilmaurya/fast_jsonparser/pull/5), thanks to [casperisfine](https://github.com/casperisfine)
* Add option for symbolize_keys, default to true in [PR #9](https://github.com/anilmaurya/fast_jsonparser/pull/9), thanks to [casperisfine](https://github.com/casperisfine)
* Parse string values as UTF-8 in [PR #10](https://github.com/anilmaurya/fast_jsonparser/pull/10), thanks to [casperisfine](https://github.com/casperisfine)