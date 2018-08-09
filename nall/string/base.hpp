#ifdef NALL_STRING_INTERNAL_HPP

namespace nall {
  struct cstring;
  struct string;
  struct lstring;
  template<typename T> inline const char* to_string(T);

  struct cstring {
    inline operator const char*() const;
    inline size_t length() const;
    inline bool operator==(const char*) const;
    inline bool operator!=(const char*) const;
    inline optional<size_t> position(const char *key) const;
    inline optional<size_t> iposition(const char *key) const;
    inline cstring& operator=(const char *data);
    inline cstring(const char *data);
    inline cstring();

  protected:
    const char *data;
  };

  struct string {
    inline static string read(const string &filename);

    inline void reserve(size_t);
    inline bool empty() const;

    template<typename... Args> inline string& assign(Args&&... args);
    template<typename... Args> inline string& append(Args&&... args);

    inline bool readfile(const string&);

    template<unsigned Limit = 0> inline string& replace(const char*, const char*);
    template<unsigned Limit = 0> inline string& ireplace(const char*, const char*);
    template<unsigned Limit = 0> inline string& qreplace(const char*, const char*);
    template<unsigned Limit = 0> inline string& iqreplace(const char*, const char*);

    inline size_t length() const;
    inline size_t capacity() const;

    template<unsigned Limit = 0> inline lstring split(const char*) const;
    template<unsigned Limit = 0> inline lstring isplit(const char*) const;
    template<unsigned Limit = 0> inline lstring qsplit(const char*) const;
    template<unsigned Limit = 0> inline lstring iqsplit(const char*) const;

    inline bool equals(const char*) const;
    inline bool iequals(const char*) const;

    inline bool wildcard(const char*) const;
    inline bool iwildcard(const char*) const;

    inline bool beginswith(const char*) const;
    inline bool ibeginswith(const char*) const;
    inline bool endswith(const char*) const;
    inline bool iendswith(const char*) const;

    inline string& lower();
    inline string& upper();
    inline string& qlower();
    inline string& qupper();
    inline string& transform(const char *before, const char *after);

    template<unsigned limit = 0> inline string& ltrim(const char *key = " ");
    template<unsigned limit = 0> inline string& rtrim(const char *key = " ");
    template<unsigned limit = 0> inline string& trim(const char *key = " ", const char *rkey = 0);

    inline optional<size_t> position(const char *key) const;
    inline optional<size_t> iposition(const char *key) const;
    inline optional<size_t> qposition(const char *key) const;
    inline optional<size_t> iqposition(const char *key) const;

    inline operator const char*() const;
    inline char* operator()();
    inline char& operator[](long);
    
    inline bool operator==(const char*) const;
    inline bool operator!=(const char*) const;
    inline bool operator< (const char*) const;
    inline bool operator<=(const char*) const;
    inline bool operator> (const char*) const;
    inline bool operator>=(const char*) const;

    inline string& operator=(const string&);
    inline string& operator=(string&&);

    template<typename... Args> inline string(Args&&... args);
    inline string(const string&);
    inline string(string&&);
    inline ~string();

    inline char* begin() { return &data[0]; }
    inline char* end() { return &data[length()]; }
    inline const char* begin() const { return &data[0]; }
    inline const char* end() const { return &data[length()]; }

    //internal functions
    inline string& assign_(const char*);
    inline string& append_(const char*);

  protected:
    char *data;
    size_t size;

    template<unsigned Limit, bool Insensitive, bool Quoted> inline string& ureplace(const char*, const char*);

  #if defined(QSTRING_H)
  public:
    inline operator QString() const;
  #endif
  };

  struct lstring : vector<string> {
    inline optional<unsigned> find(const char*) const;
    inline string concatenate(const char*) const;
    inline void append() {}
    template<typename... Args> inline void append(const string&, Args&&...);

    template<unsigned Limit = 0> inline lstring& split(const char*, const char*);
    template<unsigned Limit = 0> inline lstring& isplit(const char*, const char*);
    template<unsigned Limit = 0> inline lstring& qsplit(const char*, const char*);
    template<unsigned Limit = 0> inline lstring& iqsplit(const char*, const char*);

    inline bool operator==(const lstring&) const;
    inline bool operator!=(const lstring&) const;

    inline lstring& operator=(const lstring&);
    inline lstring& operator=(lstring&);
    inline lstring& operator=(lstring&&);

    template<typename... Args> inline lstring(Args&&... args);
    inline lstring(const lstring&);
    inline lstring(lstring&);
    inline lstring(lstring&&);

  protected:
    template<unsigned Limit, bool Insensitive, bool Quoted> inline lstring& usplit(const char*, const char*);
  };

  //compare.hpp
  inline char chrlower(char c);
  inline char chrupper(char c);
  inline int istrcmp(const char *str1, const char *str2);
  inline bool strbegin(const char *str, const char *key);
  inline bool istrbegin(const char *str, const char *key);
  inline bool strend(const char *str, const char *key);
  inline bool istrend(const char *str, const char *key);

  //convert.hpp
  inline char* strlower(char *str);
  inline char* strupper(char *str);
  inline char* qstrlower(char *str);
  inline char* qstrupper(char *str);
  inline char* strtr(char *dest, const char *before, const char *after);

  //math.hpp
  inline bool strint(const char *str, int &result);
  inline bool strmath(const char *str, int &result);

  //platform.hpp
  inline string activepath();
  inline string realpath(const string &name);
  inline string userpath();
  inline string configpath();
  inline string temppath();

  //strm.hpp
  inline size_t strmcpy(char *target, const char *source, size_t length);
  inline size_t strmcat(char *target, const char *source, size_t length);
  inline bool strccpy(char *target, const char *source, size_t length);
  inline bool strccat(char *target, const char *source, size_t length);
  inline void strpcpy(char *&target, const char *source, size_t &length);

  //strpos.hpp
  inline optional<size_t> strpos(const char *str, const char *key);
  inline optional<size_t> istrpos(const char *str, const char *key);
  inline optional<size_t> qstrpos(const char *str, const char *key);
  inline optional<size_t> iqstrpos(const char *str, const char *key);
  template<bool Insensitive = false, bool Quoted = false> inline optional<size_t> ustrpos(const char *str, const char *key);

  //trim.hpp
  template<unsigned limit = 0> inline char* ltrim(char *str, const char *key = " ");
  template<unsigned limit = 0> inline char* rtrim(char *str, const char *key = " ");
  template<unsigned limit = 0> inline char* trim(char *str, const char *key = " ", const char *rkey = 0);

  //utility.hpp
  template<bool Insensitive> alwaysinline bool chrequal(char x, char y);
  template<bool Quoted, typename T> alwaysinline bool quoteskip(T *&p);
  template<bool Quoted, typename T> alwaysinline bool quotecopy(char *&t, T *&p);
  inline string substr(const char *src, size_t start = 0, size_t length = ~0ul);
  inline string sha256(const uint8_t *data, unsigned size);

  inline char* integer(char *result, intmax_t value);
  inline char* decimal(char *result, uintmax_t value);

  template<size_t length = 0, char padding = ' '> inline string integer(intmax_t value);
  template<size_t length = 0, char padding = ' '> inline string linteger(intmax_t value);
  template<size_t length = 0, char padding = ' '> inline string decimal(uintmax_t value);
  template<size_t length = 0, char padding = ' '> inline string ldecimal(uintmax_t value);
  template<size_t length = 0, char padding = '0'> inline string hex(uintmax_t value);
  template<size_t length = 0, char padding = '0'> inline string binary(uintmax_t value);
  inline size_t fp(char *str, long double value);
  inline string fp(long double value);

  //variadic.hpp
  template<typename... Args> inline void print(Args&&... args);

  //wildcard.hpp
  inline bool wildcard(const char *str, const char *pattern);
  inline bool iwildcard(const char *str, const char *pattern);
};

#endif
