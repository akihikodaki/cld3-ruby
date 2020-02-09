/* Copyright 2017 Akihiko Odaki <akihiko.odaki.4i@stu.hosei.ac.jp>
All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#include <cstddef>
#include <iostream>
#include <string>
#include <utility>
#include "nnet_language_identifier.h"

#if defined _WIN32 || defined __CYGWIN__
  #define EXPORT __declspec(dllexport)
#else
  #define EXPORT __attribute__ ((visibility ("default")))
#endif

struct Result {
  struct {
    const char *data;
    std::size_t size;
  } language;
  struct {
    const chrome_lang_id::NNetLanguageIdentifier::SpanInfo *data;
    std::size_t size;
  } byte_ranges;
  float probability;
  float proportion;
  bool is_reliable;
};

struct OwningResult {
  OwningResult(chrome_lang_id::NNetLanguageIdentifier::Result&& result) {
    references.language = std::move(result.language);
    references.byte_ranges = std::move(result.byte_ranges);
    plain.language.data = references.language.data();
    plain.language.size = references.language.size();
    plain.byte_ranges.data = references.byte_ranges.data();
    plain.byte_ranges.size = references.byte_ranges.size();
    plain.probability = result.probability;
    plain.proportion = result.proportion;
    plain.is_reliable = result.is_reliable;
  }

  Result plain;
  struct {
    std::string language;
    std::vector<chrome_lang_id::NNetLanguageIdentifier::SpanInfo> byte_ranges;
  } references;
};

extern "C" {
  EXPORT OwningResult *NNetLanguageIdentifier_find_language(
      chrome_lang_id::NNetLanguageIdentifier *instance,
      const char *data,
      std::size_t size) {
    return new OwningResult(instance->FindLanguage(std::string(data, size)));
  }

  EXPORT std::vector<chrome_lang_id::NNetLanguageIdentifier::Result>*
  NNetLanguageIdentifier_find_top_n_most_freq_langs(
      chrome_lang_id::NNetLanguageIdentifier *instance,
      const char *data, std::size_t size, int num_langs) {
    std::string text(data, size);
    return new auto(instance->FindTopNMostFreqLangs(text, num_langs));
  }

  EXPORT void delete_NNetLanguageIdentifier(
      chrome_lang_id::NNetLanguageIdentifier *pointer) {
    delete pointer;
  }

  EXPORT void delete_result(OwningResult *pointer) {
    delete pointer;
  }

  EXPORT void delete_results(
      std::vector<chrome_lang_id::NNetLanguageIdentifier::Result> *pointer) {
    delete pointer;
  }

  EXPORT chrome_lang_id::NNetLanguageIdentifier *new_NNetLanguageIdentifier(
      int min_num_bytes, int max_num_bytes) {
    return new chrome_lang_id::NNetLanguageIdentifier(
        min_num_bytes, max_num_bytes);
  }

  EXPORT Result refer_to_nth_result(
      std::vector<chrome_lang_id::NNetLanguageIdentifier::Result> *results,
      std::size_t index) {
    Result c;
    auto& cc = (*results)[index];

    c.language.data = cc.language.data();
    c.language.size = cc.language.size();
    c.byte_ranges.data = cc.byte_ranges.data();
    c.byte_ranges.size = cc.byte_ranges.size();
    c.probability = cc.probability;
    c.proportion = cc.proportion;
    c.is_reliable = cc.is_reliable;

    return c;
  }
}
