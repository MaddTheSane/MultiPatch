#ifdef NALL_STRING_INTERNAL_HPP

//usage example:
//if(auto position = strpos(str, key)) print(position(), "\n");
//prints position of key within str; but only if it is found

namespace nall {

template<bool Insensitive, bool Quoted>
optional<size_t> ustrpos(const char *str, const char *key) {
  const char *base = str;

  while(*str) {
    if(quoteskip<Quoted>(str)) continue;
    for(unsigned n = 0;; n++) {
      if(key[n] == 0) return { true, (size_t)(str - base) };
      if(str[n] == 0) return { false, 0 };
      if(!chrequal<Insensitive>(str[n], key[n])) break;
    }
    str++;
  }

  return { false, 0 };
}

optional<size_t> strpos(const char *str, const char *key) { return ustrpos<false, false>(str, key); }
optional<size_t> istrpos(const char *str, const char *key) { return ustrpos<true, false>(str, key); }
optional<size_t> qstrpos(const char *str, const char *key) { return ustrpos<false, true>(str, key); }
optional<size_t> iqstrpos(const char *str, const char *key) { return ustrpos<true, true>(str, key); }

}

#endif
