# File including an implementation of CLD3 module. Some documentations are
# extracted from ext/cld3/ext/src/nnet_language_identifier.h.
#
# Copyright 2017 Akihiko Odaki <akihiko.odaki.4i@stu.hosei.ac.jp>
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

require "ffi"
require "rbconfig"

# Module providing an interface for Compact Language Detector v3 (CLD3)
module CLD3
  # Class for detecting the language of a document.
  class NNetLanguageIdentifier
    # Min number of bytes needed to make a prediction if the construcotr is
    # called without the corresponding parameter.
    # This is Numeric object.
    MIN_NUM_BYTES_TO_CONSIDER = 140

    # Max number of bytes needed to make a prediction if the construcotr is
    # called without the corresponding parameter.
    # This is Numeric object.
    MAX_NUM_BYTES_TO_CONSIDER = 700

    # Max number of input bytes to process.
    # This is Numeric object.
    MAX_NUM_INPUT_BYTES_TO_CONSIDER = 10000

    # Predictions with probability greater than or equal to this threshold are
    # marked as reliable. This threshold was optimized on a set of text segments
    # extracted from wikipedia, and results in an overall precision, recall,
    # and f1 equal to 0.9760, 0.9624, and 0.9692, respectively.
    # This is Numeric object.
    RELIABILITY_THRESHOLD = 0.7

    # Reliability threshold for the languages hr and bs.
    # This is Numeric object.
    RELIABILITY_HR_BS_THRESHOLD = 0.5

    # Holds probability that Span, specified by start/end indices, is a given
    # language. The langauge is not stored here; it can be found in Result, which
    # holds an Array of SpanInfo.
    SpanInfo = Struct.new(:start_index, :end_index, :probability)

    # Information about a predicted language.
    # This is an instance of Struct with the following members:
    #
    # [language]    This is symbol.
    #
    # [probability] Language probability. This is Numeric object.
    #
    # [reliable?]   Whether the prediction is reliable. This is true or false.
    #
    # [proportion]  Proportion of bytes associated with the language. If
    #               #find_language is called, this variable is set to 1.
    #               This is Numeric object.
    #
    # [byte_ranges] Specifies the byte ranges in UTF-8 that |language| applies to.
    #               This is an Array of SpanInfo.
    Result = Struct.new(:language, :probability, :reliable?, :proportion, :byte_ranges)

    # The arguments are two String objects.
    def initialize(min_num_bytes = MIN_NUM_BYTES_TO_CONSIDER, max_num_bytes = MAX_NUM_BYTES_TO_CONSIDER)
      @cc = Unstable::NNetLanguageIdentifier::Pointer.new(Unstable.new_NNetLanguageIdentifier(min_num_bytes, max_num_bytes))
    end

    # Finds the most likely language for the given text, along with additional
    # information (e.g., probability). The prediction is based on the first N
    # bytes where N is the minumum between the number of interchange valid UTF8
    # bytes and +max_num_bytes_+. If N is less than +min_num_bytes_+ long, then
    # this function returns nil.
    # The argument is a String object.
    # The returned value of this function is an instance of Result.
    def find_language(text)
      text_utf8 = text.encode(Encoding::UTF_8)
      pointer = FFI::MemoryPointer.new(:char, text_utf8.bytesize)

      begin
        pointer.put_bytes(0, text_utf8)

        result = Unstable.NNetLanguageIdentifier_find_language(@cc, pointer, text_utf8.bytesize)
        begin
          convert_result Unstable::NNetLanguageIdentifier::Result.new(result)
        ensure
          Unstable.delete_result result
        end
      ensure
        pointer.free
      end
    end

    # Splits the input text (up to the first byte, if any, that is not
    # interchange valid UTF8) into spans based on the script, predicts a language
    # for each span, and returns a vector storing the top num_langs most frequent
    # languages along with additional information (e.g., proportions). The number
    # of bytes considered for each span is the minimum between the size of the
    # span and +max_num_bytes_+. If more languages are requested than what is
    # available in the input, then the number of the returned elements will be
    # the number of the latter. Also, if the size of the span is less than
    # +min_num_bytes_+ long, then the span is skipped. If the input text is too
    # long, only the first +MAX_NUM_INPUT_BYTES_TO_CONSIDER+ bytes are processed.
    # The first argument is a String object.
    # The second argument is Numeric object.
    # The returned value of this functions is an Array of Result instances.
    def find_top_n_most_freq_langs(text, num_langs)
      text_utf8 = text.encode(Encoding::UTF_8)
      pointer = FFI::MemoryPointer.new(:char, text_utf8.bytesize)

      begin
        pointer.put_bytes(0, text_utf8)

        results = Unstable.NNetLanguageIdentifier_find_top_n_most_freq_langs(@cc, pointer, text_utf8.bytesize, num_langs)
        begin
          num_langs.times
            .lazy
            .map { |index| convert_result Unstable.refer_to_nth_result(results, index) }
            .take_while { |result| !result.nil? }
            .to_a
        ensure
          Unstable.delete_results results
        end
      ensure
        pointer.free
      end
    end

    private

    def convert_result(result)
      language = result[:language_data].read_bytes(result[:language_size])
      return nil if language == "und"

      cursor = result[:byte_ranges_data]
      byte_ranges = result[:byte_ranges_size].times.map do
        info = Unstable::NNetLanguageIdentifier::SpanInfo.new(cursor)
        cursor += Unstable::NNetLanguageIdentifier::SpanInfo.size
        SpanInfo.new(info[:start_index], info[:end_index], info[:probability])
      end

      Result.new(
          language.to_sym,
          result[:probability],
          result[:reliable?],
          result[:proportion],
          byte_ranges)
    end
  end

  # Encapsulates the TaskContext specifying only the parameters for the model.
  # The model weights are loaded statically.
  module TaskContextParams
    # This is an frozen Array object containing symbols.
    LANGUAGE_NAMES = [
      :eo, :co, :eu, :ta, :de, :mt, :ps, :te, :su, :uz, :'zh-Latn', :ne,
      :nl, :sw, :sq, :hmn, :ja, :no, :mn, :so, :ko, :kk, :sl, :ig,
      :mr, :th, :zu, :ml, :hr, :bs, :lo, :sd, :cy, :hy, :uk, :pt,
      :lv, :iw, :cs, :vi, :jv, :be, :km, :mk, :tr, :fy, :am, :zh,
      :da, :sv, :fi, :ht, :af, :la, :id, :fil, :sm, :ca, :el, :ka,
      :sr, :it, :sk, :ru, :'ru-Latn', :bg, :ny, :fa, :haw, :gl, :et,
      :ms, :gd, :'bg-Latn', :ha, :is, :ur, :mi, :hi, :bn, :'hi-Latn', :fr,
      :yi, :hu, :xh, :my, :tg, :ro, :ar, :lb, :'el-Latn', :st, :ceb,
      :kn, :az, :si, :ky, :mg, :en, :gu, :es, :pl, :'ja-Latn', :ga, :lt,
      :sn, :yo, :pa, :ku,
    ].freeze
  end

  module Unstable
    extend FFI::Library

    ffi_lib File.join(File.expand_path(File.dirname(__FILE__)), "..", "ext", "cld3", "libcld3." + RbConfig::CONFIG["DLEXT"])

    module NNetLanguageIdentifier
      class Pointer < FFI::AutoPointer
        def self.release(pointer)
          Unstable.delete_NNetLanguageIdentifier(pointer)
        end
      end

      class SpanInfo < FFI::Struct
        layout :start_index, :int, :end_index, :int, :probability, :float
      end

      class Result < FFI::Struct
        layout :language_data, :pointer, :language_size, :size_t, :byte_ranges_data, :pointer, :byte_ranges_size, :size_t, :probability, :float, :proportion, :float, :reliable?, :bool
      end
    end

    attach_function :delete_NNetLanguageIdentifier, [ :pointer ], :void

    attach_function :delete_result, [ :pointer ], :void

    attach_function :delete_results, [ :pointer ], :void

    attach_function :new_NNetLanguageIdentifier, [ :int, :int ], :pointer

    attach_function :refer_to_nth_result, [ :pointer, :size_t ], NNetLanguageIdentifier::Result.by_value

    attach_function :NNetLanguageIdentifier_find_language,
        [ :pointer, :buffer_in, :size_t ], :pointer

    attach_function :NNetLanguageIdentifier_find_top_n_most_freq_langs,
        [ :pointer, :buffer_in, :size_t, :int ], :pointer
  end

  private_constant :Unstable
end
