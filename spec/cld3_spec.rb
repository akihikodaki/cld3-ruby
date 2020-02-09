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
#==============================================================================

require "bundler/setup"
Bundler.setup

require "cld3"

describe CLD3::NNetLanguageIdentifier do
  context "initialized without parameters" do
    let(:lang_id) { described_class.new }

    describe "#find_language" do
      subject { lang_id.find_language("This text is written in English.") }
      it { is_expected.to be_nil }
    end
  end

  # See ext/cld3/ext/src/language_identifier_main.cc
  context "initialized with custom parameters" do
    let(:lang_id) { described_class.new(0, 1000) }

    describe "#find_language" do
      subject { lang_id.find_language text }

      context "with an English text" do
        let(:text) { "This text is written in English." }
        it { is_expected.to eq(CLD3::NNetLanguageIdentifier::Result.new(:en, 0.9996357560157776, true, 1.0, [])) }
      end
    end

    describe "#find_top_n_most_freq_langs" do
      subject { lang_id.find_top_n_most_freq_langs text, 3 }

      context "with an English text followed by a Russian text" do
        let(:text) { "This piece of text is in English. Този текст е на Български." }
        it {
          is_expected.to eq([
            CLD3::NNetLanguageIdentifier::Result.new(:bg, 0.9173890948295593, true, 0.5853658318519592, [
              CLD3::NNetLanguageIdentifier::SpanInfo.new(34, 81, 0.9173890948295593)
            ]),
            CLD3::NNetLanguageIdentifier::Result.new(:en, 0.9999790191650391, true, 0.4146341383457184, [
              CLD3::NNetLanguageIdentifier::SpanInfo.new(0, 34, 0.9999790191650391)
            ]),
          ])
        }
      end
    end
  end
end
