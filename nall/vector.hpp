#ifndef NALL_VECTOR_HPP
#define NALL_VECTOR_HPP

#include <algorithm>
#include <initializer_list>
#include <new>
#include <type_traits>
#include <utility>
#include "algorithm.hpp"
#include "bit.hpp"
#include "sort.hpp"
#include "utility.hpp"

namespace nall {
  template<typename T> struct vector {
    struct exception_out_of_bounds{};

  protected:
    T *pool;
    unsigned long poolsize;
    unsigned long objectsize;

  public:
    operator bool() const { return pool; }
    T* data() { return pool; }

    bool empty() const { return objectsize == 0; }
    unsigned long size() const { return objectsize; }
    unsigned long capacity() const { return poolsize; }

    T* move() {
      T *result = pool;
      pool = nullptr;
      poolsize = 0;
      objectsize = 0;
      return result;
    }

    void reset() {
      if(pool) {
        for(unsigned long n = 0; n < objectsize; n++) pool[n].~T();
        free(pool);
      }
      pool = nullptr;
      poolsize = 0;
      objectsize = 0;
    }

    void reserve(unsigned long size) {
      size = bit::round(size);  //amortize growth
      T *copy = (T*)calloc(size, sizeof(T));
      for(unsigned long n = 0; n < min(size, objectsize); n++) new(copy + n) T(pool[n]);
      for(unsigned long n = 0; n < objectsize; n++) pool[n].~T();
      free(pool);
      pool = copy;
      poolsize = size;
      objectsize = min(size, objectsize);
    }

    //requires trivial constructor
    void resize(unsigned long size) {
      if(size == objectsize) return;
      if(size < objectsize) return reserve(size);
      while(size > objectsize) append(T());
    }

    template<typename... Args>
    void append(const T& data, Args&&... args) {
      append(data);
      append(std::forward<Args>(args)...);
    }

    void append(const T& data) {
      if(objectsize + 1 > poolsize) reserve(objectsize + 1);
      new(pool + objectsize++) T(data);
    }

    bool appendonce(const T& data) {
      if(find(data) == true) return false;
      append(data);
      return true;
    }

    void insert(unsigned long position, const T& data) {
      append(data);
      for(signed long n = size() - 1; n > position; n--) pool[n] = pool[n - 1];
      pool[position] = data;
    }

    void prepend(const T& data) {
      insert(0, data);
    }

    void remove(unsigned long index = ~0ul, unsigned count = 1) {
      if(index == ~0) index = objectsize ? objectsize - 1 : 0;
      for(unsigned long n = index; count + n < objectsize; n++) pool[n] = pool[count + n];
      objectsize = (count + index >= objectsize) ? index : objectsize - count;
    }

    T take(unsigned long index = ~0ul) {
      if(index == ~0) index = objectsize ? objectsize - 1 : 0;
      if(index >= objectsize) throw exception_out_of_bounds();
      T item = pool[index];
      remove(index);
      return item;
    }

    void reverse() {
      unsigned long pivot = size() / 2;
      for(unsigned l = 0, r = size() - 1; l < pivot; l++, r--) {
        std::swap(pool[l], pool[r]);
      }
    }

    void sort() {
      nall::sort(pool, objectsize);
    }

    template<typename Comparator> void sort(const Comparator &lessthan) {
      nall::sort(pool, objectsize, lessthan);
    }

    optional<unsigned long> find(const T& data) {
      for(unsigned long n = 0; n < size(); n++) if(pool[n] == data) return { true, n };
      return { false, 0u };
    }

    T& first() {
      if(objectsize == 0) throw exception_out_of_bounds();
      return pool[0];
    }

    T& last() {
      if(objectsize == 0) throw exception_out_of_bounds();
      return pool[objectsize - 1];
    }

    //access
    inline T& operator[](unsigned long position) {
      if(position >= objectsize) throw exception_out_of_bounds();
      return pool[position];
    }

    inline const T& operator[](unsigned long position) const {
      if(position >= objectsize) throw exception_out_of_bounds();
      return pool[position];
    }

    inline T& operator()(unsigned long position) {
      if(position >= poolsize) reserve(position + 1);
      while(position >= objectsize) append(T());
      return pool[position];
    }

    inline const T& operator()(unsigned long position, const T& data) const {
      if(position >= objectsize) return data;
      return pool[position];
    }

    //iteration
    T* begin() { return &pool[0]; }
    T* end() { return &pool[objectsize]; }
    const T* begin() const { return &pool[0]; }
    const T* end() const { return &pool[objectsize]; }

    //copy
    inline vector& operator=(const vector &source) {
      reset();
      reserve(source.capacity());
      for(auto &data : source) append(data);
      return *this;
    }

    vector(const vector &source) : pool(nullptr), poolsize(0), objectsize(0) {
      operator=(source);
    }

    //move
    inline vector& operator=(vector &&source) {
      reset();
      pool = source.pool, poolsize = source.poolsize, objectsize = source.objectsize;
      source.pool = nullptr, source.poolsize = 0, source.objectsize = 0;
      return *this;
    }

    vector(vector &&source) : pool(nullptr), poolsize(0), objectsize(0) {
      operator=(std::move(source));
    }

    //construction
    vector() : pool(nullptr), poolsize(0), objectsize(0) {
    }

    vector(std::initializer_list<T> list) : pool(nullptr), poolsize(0), objectsize(0) {
      for(auto &data : list) append(data);
    }

    ~vector() {
      reset();
    }
  };
}

#endif
