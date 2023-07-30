#include "ruby.h"

#include "simdjson.h"

VALUE rb_eFastJsonparserUnknownError, rb_eFastJsonparserParseError;

using namespace simdjson;

typedef struct {
    dom::parser *parser;
} parser_t;

static void Parser_delete(void *ptr) {
    parser_t *data = (parser_t*) ptr;
    delete data->parser;
}

static size_t Parser_memsize(const void *parser) {
    return sizeof(dom::parser); // TODO: low priority, figure the real size, e.g. internal buffers etc.
}

static const rb_data_type_t parser_data_type = {
    "Parser",
    { 0, Parser_delete, Parser_memsize, },
    0, 0, RUBY_TYPED_FREE_IMMEDIATELY
};

static VALUE parser_allocate(VALUE klass) {
    parser_t *data;
    VALUE obj = TypedData_Make_Struct(klass, parser_t, &parser_data_type, data);
    data->parser = new dom::parser;
    return obj;
}

static inline dom::parser * get_parser(VALUE self) {
    parser_t *data;
    TypedData_Get_Struct(self, parser_t, &parser_data_type, data);
    return data->parser;
}

// Convert tape to Ruby's Object
static VALUE make_ruby_object(dom::element element, bool symbolize_keys)
{
    switch (element.type())
    {
    case dom::element_type::ARRAY:
    {
        VALUE ary = rb_ary_new();
        for (dom::element x : element)
        {
            VALUE e = make_ruby_object(x, symbolize_keys);
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
            VALUE k = rb_utf8_str_new(view.data(), view.size());
            if (symbolize_keys)
            {
                k = ID2SYM(rb_intern_str(k));
            }
            VALUE v = make_ruby_object(field.value, symbolize_keys);
            rb_hash_aset(hash, k, v);
        }
        return hash;
    }
    case dom::element_type::INT64:
    {
        if (SIZEOF_LONG == 4) {
          return LL2NUM(element.get<int64_t>());
        } else {
          return LONG2NUM(element.get<int64_t>());
        }
    }
    case dom::element_type::UINT64:
    {
        if (SIZEOF_LONG_LONG == 4) {
            return ULL2NUM(element.get<uint64_t>());
        } else {
            return ULONG2NUM(element.get<uint64_t>());
        }
    }
    case dom::element_type::DOUBLE:
    {
        return DBL2NUM(double(element));
    }
    case dom::element_type::STRING:
    {
        std::string_view view(element);
        return rb_utf8_str_new(view.data(), view.size());
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

static VALUE rb_fast_jsonparser_parse(VALUE self, VALUE arg, VALUE symbolize_keys)
{
    Check_Type(arg, T_STRING);
    dom::parser *parser = get_parser(self);

    auto [doc, error] = parser->parse(RSTRING_PTR(arg), RSTRING_LEN(arg));
    if (error != SUCCESS)
    {
        rb_raise(rb_eFastJsonparserParseError, "%s", error_message(error));
    }
    return make_ruby_object(doc, RTEST(symbolize_keys));
}

static VALUE rb_fast_jsonparser_load(VALUE self, VALUE arg, VALUE symbolize_keys)
{
    Check_Type(arg, T_STRING);
    dom::parser *parser = get_parser(self);

    auto [doc, error] = parser->load(RSTRING_PTR(arg));
    if (error != SUCCESS)
    {
        rb_raise(rb_eFastJsonparserParseError, "%s", error_message(error));
    }
    return make_ruby_object(doc, RTEST(symbolize_keys));
}

static VALUE rb_fast_jsonparser_load_many(VALUE self, VALUE arg, VALUE symbolize_keys, VALUE batch_size)
{
    Check_Type(arg, T_STRING);
    Check_Type(batch_size, T_FIXNUM);
    dom::parser *parser = get_parser(self);

    try {
        auto [docs, error] = parser->load_many(RSTRING_PTR(arg), FIX2INT(batch_size));
        if (error != SUCCESS)
        {
            rb_raise(rb_eFastJsonparserParseError, "%s", error_message(error));
        }

        for (dom::element doc : docs)
        {
            rb_yield(make_ruby_object(doc, RTEST(symbolize_keys)));
        }

        return Qnil;
    }
    catch (simdjson::simdjson_error error)
    {
        rb_raise(rb_eFastJsonparserUnknownError, "%s", error.what());
    }
}

extern "C"
{

    void Init_fast_jsonparser(void)
    {
        VALUE rb_mFastJsonparser = rb_const_get(rb_cObject, rb_intern("FastJsonparser"));
        VALUE rb_cFastJsonparserNative = rb_const_get(rb_mFastJsonparser, rb_intern("Native"));

        rb_define_alloc_func(rb_cFastJsonparserNative, parser_allocate);
        rb_define_method(rb_cFastJsonparserNative, "_parse", reinterpret_cast<VALUE (*)(...)>(rb_fast_jsonparser_parse), 2);
        rb_define_method(rb_cFastJsonparserNative, "_load", reinterpret_cast<VALUE (*)(...)>(rb_fast_jsonparser_load), 2);
        rb_define_method(rb_cFastJsonparserNative, "_load_many", reinterpret_cast<VALUE (*)(...)>(rb_fast_jsonparser_load_many), 3);

        rb_eFastJsonparserParseError = rb_const_get(rb_mFastJsonparser, rb_intern("ParseError"));
        rb_global_variable(&rb_eFastJsonparserParseError);
        rb_eFastJsonparserUnknownError = rb_const_get(rb_mFastJsonparser, rb_intern("UnknownError"));
        rb_global_variable(&rb_eFastJsonparserUnknownError);
    }
}
