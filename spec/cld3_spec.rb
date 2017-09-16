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
  it "has default parameters and deals with unknown language" do
    expect(
        described_class
          .new
          .find_language("This text is written in English."))
      .to eq(CLD3::NNetLanguageIdentifier::Result.new(nil, 0, false, 0))
  end

  it "can have custom parameters and deals with known language" do
    # See ext/cld3/ext/src/language_identifier_main.cc
    expect(
        described_class
          .new(0, 1000)
          .find_language("This text is written in English."))
      .to eq(CLD3::NNetLanguageIdentifier::Result.new(:en, 0.9996357560157776, true, 1.0))
  end
end
