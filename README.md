# cld3-ruby
cld3-ruby is an interface of [Compact Language Detector v3 (CLD3)](https://github.com/google/cld3) for Ruby.

## Usage

```ruby
require 'cld3'

cld3 = CLD3::NNetLanguageIdentifier.new(0, 1000)

cld3.find_language("こんにちは") # => #<struct Struct::Result language=:ja, probability=1.0, reliable?=true, proportion=1.0, byte_ranges=[]>

cld3.find_language("This is a pen.") # => #<struct Struct::Result language=:en, probability=0.9999408721923828, reliable?=true, proportion=1.0, byte_ranges=[]>

cld3.find_language("здравствуйте") # => #<struct Struct::Result language=:ru, probability=0.3140212297439575, reliable?=false, proportion=1.0, byte_ranges=[]>
```

## Installation
### Prerequisites
* [Bundler](http://bundler.io/)
* C++ compiler
* [Protocol buffers](https://developers.google.com/protocol-buffers/)
* [Rake](https://ruby.github.io/rake/)
* [RubyGems](https://rubygems.org/)

### Instructions
I (Akihiko Odaki) recommend to setup this library installing via `gem`.

You can also build this library by yourself. `Rakefile` includes a Rake task to
put this code into files buildable as a gem. Build a gem with `rake` command.

### Platform-specific information

#### FreeBSD
FreeBSD port is available as `rubygem-cld3` in `textproc` category.

https://svnweb.freebsd.org/ports/head/textproc/rubygem-cld3/

#### JRuby
JRuby has a bug which prevents the feature detection. Apply the following
change:
https://github.com/jruby/jruby/pull/4118/commits/edad375ef4dcf195b19ce0afe4befac66468c736

#### OpenBSD
Ruby has a bug which recognizes non-fatal linker warnings as fatal. Apply the
following patch to Ruby to workaround the bug.

```diff
--- a/lib/mkmf.rb
+++ b/lib/mkmf.rb
@@ -657,7 +657,7 @@ def with_ldflags(flags)
   end
 
   def try_ldflags(flags, opts = {})
-    try_link(MAIN_DOES_NOTHING, flags, {:werror => true}.update(opts))
+    try_link(MAIN_DOES_NOTHING, flags, {:werror => false}.update(opts))
   end
 
   def append_ldflags(flags, *opts)
```

### Troubleshooting
`gem install cld3` triggers native library building. If it fails, you are likely
to missing required facilities. Make sure C++ compiler and protocol buffers
is installed. I recommend [GCC](https://gcc.gnu.org/) as a C++ compiler. Ruby is
likely to need [pkg-config](https://www.freedesktop.org/wiki/Software/pkg-config/)
as well.

Runtime errors are likely to be issues of [FFI](https://github.com/ffi/ffi) or
programming errors. Make sure they are all correct.

If you cannot identify the cause of your problem, run spec of this library and
see whether the problem is reproducable with it or not. Spec is not included in
the gem, so clone the source code repository and then run `rake spec`.
The source code repository is at
https://github.com/akihikodaki/cld3-ruby.

In case you cannot solve your problem by yourself and cannot help abandoning or
find an issue in this library, please open an issue at
https://github.com/akihikodaki/cld3-ruby/issues.

If you found an issue and managed to fix it and agree to share the fix under
[Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0), please open a pull
request at https://github.com/akihikodaki/cld3-ruby/pulls. Your contribution
would be appreciated by other users and recorded with Git.

## Versioning

The version has 3 parts: major, minor, and patch. They are joined with . as
delimiters in the order.

The increment of the major version and the minor version indicates it can involve
any change.

The increment of the patch version indicates there is no change of the supported
languages and no change of the existing APIs.

## Contact

To ask questions or report issues please open issues at
https://github.com/akihikodaki/cld3-ruby/issues.

## Credits

This program was written by Akihiko Odaki and other contributors. CLD3 was
written by its own authors.
