
# Copyright 2021 Akihiko Odaki <akihiko.odaki@gmail.com>
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

module CLD3
  module Unstable
    extend FFI::Library

    ffi_lib File.join(__dir__, "..", "libcld3." + RbConfig::CONFIG["DLEXT"])

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
