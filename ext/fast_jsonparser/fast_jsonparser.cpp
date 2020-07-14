#include "ruby.h"

#include "simdjson.h"

VALUE rb_mFastJsonparser;

VALUE rb_eFastJsonparserParseError;

using namespace simdjson;

// Convert tape to Ruby's Object
static VALUE make_ruby_object(dom::element element)
{
    auto t = element.type();
    if (t == dom::element_type::ARRAY)
    {
        VALUE ary = rb_ary_new();
        for (dom::element x : element)
        {
            VALUE e = make_ruby_object(x);
            rb_ary_push(ary, e);
        }
        return ary;
    }
    else if (t == dom::element_type::OBJECT)
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
    else if (t == dom::element_type::INT64)
    {
        return LONG2NUM(element.get<int64_t>());
    }
    else if (t == dom::element_type::UINT64)
    {
        return ULONG2NUM(element.get<uint64_t>());
    }
    else if (t == dom::element_type::DOUBLE)
    {
        return DBL2NUM(double(element));
    }
    else if (t == dom::element_type::STRING)
    {
        std::string_view view(element);
        return rb_str_new(view.data(), view.size());
    }
    else if (t == dom::element_type::BOOL)
    {
        return bool(element) ? Qtrue : Qfalse;
    }
    else if (t == dom::element_type::NULL_VALUE)
    {
        return Qnil;
    }
    // unknown case (bug)
    rb_raise(rb_eException, "[BUG] must not happen");
}

static VALUE rb_fast_jsonparser_parse(VALUE self, VALUE arg)
{
    Check_Type(arg, T_STRING);

    dom::parser parser;
    auto [doc, error] = parser.parse(RSTRING_PTR(arg), RSTRING_LEN(arg));
    if (error == SUCCESS)
    {
        return make_ruby_object(doc);
    }
    // TODO better error handling
    rb_raise(rb_eFastJsonparserParseError, "parse error");
    return Qnil;
}

static VALUE rb_fast_jsonparser_load(VALUE self, VALUE arg)
{
    Check_Type(arg, T_STRING);

    dom::parser parser;
    auto [doc, error] = parser.load(RSTRING_PTR(arg));
    if (error == SUCCESS)
    {
        return make_ruby_object(doc);
    }
    // TODO better error handling
    rb_raise(rb_eFastJsonparserParseError, "parse error");
    return Qnil;
}

static VALUE rb_fast_jsonparser_load_many(VALUE self, VALUE arg)
{
    Check_Type(arg, T_STRING);

    dom::parser parser;
    auto [docs, error] = parser.load_many(RSTRING_PTR(arg));
    if (error == SUCCESS)
    {
        for (dom::element doc : docs)
        {
            if (rb_block_given_p())
            {
                rb_yield(make_ruby_object(doc));
            }
        }
        return Qnil;
    }
    rb_raise(rb_eFastJsonparserParseError, "parse error");
    return Qnil;
}

extern "C"
{

    void Init_fast_jsonparser(void)
    {
        rb_mFastJsonparser = rb_define_module("FastJsonparser");
        rb_eFastJsonparserParseError = rb_define_class_under(rb_mFastJsonparser, "ParseError", rb_eStandardError);
        rb_define_module_function(rb_mFastJsonparser, "parse", reinterpret_cast<VALUE (*)(...)>(rb_fast_jsonparser_parse), 1);
        rb_define_module_function(rb_mFastJsonparser, "load", reinterpret_cast<VALUE (*)(...)>(rb_fast_jsonparser_load), 1);
        rb_define_module_function(rb_mFastJsonparser, "load_many", reinterpret_cast<VALUE (*)(...)>(rb_fast_jsonparser_load_many), 1);
    }
}
