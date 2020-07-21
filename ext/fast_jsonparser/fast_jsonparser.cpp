#include "ruby.h"

#include "simdjson.h"

VALUE rb_eFastJsonparserUnknownError, rb_eFastJsonparserParseError;

using namespace simdjson;

// Convert tape to Ruby's Object
static VALUE make_ruby_object(dom::element element)
{
    switch (element.type())
    {
        case dom::element_type::ARRAY:
        {
            VALUE ary = rb_ary_new();
            for (dom::element x : element)
            {
                VALUE e = make_ruby_object(x);
                rb_ary_push(ary, e);
            }
            return ary;
        }
        case dom::element_type::OBJECT:
        {
            VALUE hash = rb_hash_new();
            for (dom::key_value_pair field : dom::object(element))
            {
                std::string_view view(field.key);
                VALUE k = rb_intern(view.data());
                VALUE v = make_ruby_object(field.value);
                rb_hash_aset(hash, ID2SYM(k), v);
            }
            return hash;
        }
        case dom::element_type::INT64:
        {
            return LONG2NUM(element.get<int64_t>());
        }
        case dom::element_type::UINT64:
        {
            return ULONG2NUM(element.get<uint64_t>());
        }
        case dom::element_type::DOUBLE:
        {
            return DBL2NUM(double(element));
        }
        case dom::element_type::STRING:
        {
            std::string_view view(element);
            return rb_str_new(view.data(), view.size());
        }
        case dom::element_type::BOOL:
        {
            return bool(element) ? Qtrue : Qfalse;
        }
        case dom::element_type::NULL_VALUE:
        {
            return Qnil;
        }
    }
    // unknown case (bug)
    rb_raise(rb_eException, "[BUG] must not happen");
}

static VALUE rb_fast_jsonparser_parse(VALUE self, VALUE arg)
{
    Check_Type(arg, T_STRING);

    dom::parser parser;
    auto [doc, error] = parser.parse(RSTRING_PTR(arg), RSTRING_LEN(arg));
    if (error != SUCCESS)
    {
        rb_raise(rb_eFastJsonparserParseError, "%s", error_message(error));
    }
    return make_ruby_object(doc);
}

static VALUE rb_fast_jsonparser_load(VALUE self, VALUE arg)
{
    Check_Type(arg, T_STRING);

    dom::parser parser;
    auto [doc, error] = parser.load(RSTRING_PTR(arg));
    if (error != SUCCESS)
    {
        rb_raise(rb_eFastJsonparserParseError, "%s", error_message(error));
    }
    return make_ruby_object(doc);
}

static VALUE rb_fast_jsonparser_load_many(VALUE self, VALUE arg, VALUE batch_size)
{
    Check_Type(arg, T_STRING);
    Check_Type(batch_size, T_FIXNUM);

    try {
        dom::parser parser;
        auto [docs, error] = parser.load_many(RSTRING_PTR(arg), FIX2INT(batch_size));
        if (error != SUCCESS)
        {
            rb_raise(rb_eFastJsonparserParseError, "%s", error_message(error));
        }

        for (dom::element doc : docs)
        {
            rb_yield(make_ruby_object(doc));
        }

        return Qnil;
    } catch (simdjson::simdjson_error error) {
        rb_raise(rb_eFastJsonparserUnknownError, "%s", error.what());
    }
}

extern "C"
{

    void Init_fast_jsonparser(void)
    {
        VALUE rb_mFastJsonparser = rb_const_get(rb_cObject, rb_intern("FastJsonparser"));

        rb_define_module_function(rb_mFastJsonparser, "parse", reinterpret_cast<VALUE (*)(...)>(rb_fast_jsonparser_parse), 1);
        rb_define_module_function(rb_mFastJsonparser, "load", reinterpret_cast<VALUE (*)(...)>(rb_fast_jsonparser_load), 1);
        rb_define_module_function(rb_mFastJsonparser, "_load_many", reinterpret_cast<VALUE (*)(...)>(rb_fast_jsonparser_load_many), 2);

        rb_eFastJsonparserParseError = rb_const_get(rb_mFastJsonparser, rb_intern("ParseError"));
        rb_global_variable(&rb_eFastJsonparserParseError);
        rb_eFastJsonparserUnknownError = rb_const_get(rb_mFastJsonparser, rb_intern("UnknownError"));
        rb_global_variable(&rb_eFastJsonparserUnknownError);

    }
}
