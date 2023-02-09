# Copyright 2017 Akihiko Odaki <akihiko.odaki@gmail.com>
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

require "rake/clean"
require "rubygems"
require "rubygems/package"

ENV["RBS_TEST_TARGET"] = "CLD3::*"

# Copied from ext/cld3/ext/src/BUILD.gn
ext_name = FileList[
  "base.cc",
  "base.h",
  "casts.h",
  "embedding_feature_extractor.cc",
  "embedding_feature_extractor.h",
  "embedding_network.cc",
  "embedding_network.h",
  "embedding_network_params.h",
  "feature_extractor.cc",
  "feature_extractor.h",
  "feature_types.cc",
  "feature_types.h",
  "float16.h",
  "fml_parser.cc",
  "fml_parser.h",
  "language_identifier_features.cc",
  "language_identifier_features.h",
  "lang_id_nn_params.cc",
  "lang_id_nn_params.h",
  "nnet_language_identifier.cc",
  "nnet_language_identifier.h",
  "registry.cc",
  "registry.h",
  "relevant_script_feature.cc",
  "relevant_script_feature.h",
  "script_detector.h",
  "sentence_features.cc",
  "sentence_features.h",
  "simple_adder.h",
  "script_span/fixunicodevalue.cc",
  "script_span/fixunicodevalue.h",
  "script_span/generated_entities.cc",
  "script_span/generated_ulscript.cc",
  "script_span/generated_ulscript.h",
  "script_span/getonescriptspan.cc",
  "script_span/getonescriptspan.h",
  "script_span/integral_types.h",
  "script_span/offsetmap.cc",
  "script_span/offsetmap.h",
  "script_span/port.h",
  "script_span/stringpiece.h",
  "script_span/text_processing.cc",
  "script_span/text_processing.h",
  "script_span/utf8acceptinterchange.h",
  "script_span/utf8prop_lettermarkscriptnum.h",
  "script_span/utf8repl_lettermarklower.h",
  "script_span/utf8scannot_lettermarkspecial.h",
  "script_span/utf8statetable.cc",
  "script_span/utf8statetable.h",
  "task_context.cc",
  "task_context.h",
  "task_context_params.cc",
  "task_context_params.h",
  "unicodetext.cc",
  "unicodetext.h",
  "utils.cc",
  "utils.h",
  "workspace.cc",
  "workspace.h"
]

int_path = FileList[
  "Gemfile",
  "LICENSE",
  "README.md",
  "Steepfile",
  "cld3.gemspec",
  "ext/cld3/cld_3/protos/feature_extractor.pb.h",
  "ext/cld3/cld_3/protos/sentence.pb.h",
  "ext/cld3/cld_3/protos/task_spec.pb.h",
  "ext/cld3/extconf.rb",
  "ext/cld3/libcld3.def",
  "ext/cld3/nnet_language_identifier_c.cc",
  "lib/cld3/unstable.rb",
  "lib/cld3.rb",
  "sig/cld3.rbs",
  "spec/cld3_spec.rb"
]

ext_intermediate = ext_name.pathmap("intermediate/ext/cld3/%p")
int_intermediate = int_path.pathmap("intermediate/%p")

desc "Run the default task"
task :default => :package

desc "Run the tests"
task "spec" => "intermediate/ext/cld3/Makefile" do
  sh "make -C intermediate/ext/cld3 install sitearchdir=../../lib sitelibdir=../../lib"
  sh "cd intermediate && bundle exec rspec"
end

desc "Run Steep"
task "steep" => :prepare do
  sh "cd intermediate && bundle exec steep check"
end

file "intermediate/ext/cld3/Makefile" => :prepare do
  sh "cd intermediate/ext/cld3 && ruby extconf.rb"
end

task :package => :prepare do
  chdir "intermediate" do
    Gem::Package.build Gem::Specification.load("cld3.gemspec")
  end
end

desc "Prepare files for building gem and testing in intermediate directory"
task :prepare =>
    ext_intermediate + int_intermediate << "intermediate/LICENSE_CLD3" do
  rm_rf "intermediate/ext/cld3/script_span"
  sh "cd intermediate && bundle config path vendor/bundle && bundle install"
end

ext_name.each { |name|
  file File.join("intermediate/ext/cld3", name) =>
      [ File.join("ext/cld3/ext/src", name), "intermediate/ext/cld3" ] do |t|
    cp t.sources[0], t.sources[1], preserve: true
  end
}

int_path.each { |path|
  target_file_path = File.join("intermediate", path)
  target_directory_path = File.dirname(target_file_path)

  file target_file_path => [ File.join(path), target_directory_path ] do |t|
    cp t.sources[0], t.name
  end

  directory target_directory_path
}

file "intermediate/LICENSE_CLD3" =>
    [ "ext/cld3/ext/LICENSE", "intermediate" ] do |t|
  cp t.sources[0], t.name
end

directory "intermediate"
directory "intermediate/ext/cld3"

CLEAN.include("intermediate/LICENSE_CLD3")
CLEAN.include("intermediate/cld3-*.gem")
CLEAN.include("intermediate/ext")
CLEAN.include(int_intermediate)

CLOBBER.include("intermediate")
